require "digest/sha256"
require "sqlite3"

class Db::ImportDenaroData < LuckyTask::Task
  summary "Import a Denaro database"

  arg :file, "Denaro SQLite file to import",
    shortcut: "-f"

  arg :username, "Username to load the data under",
    shortcut: "-u"

  def call
    user = UserQuery.new.email(username).first
    DB.open("sqlite3://#{file}") do |db|
      load_tags(db, user)
      account = load_account(db, user)
      load_transactions(db, user, account)
    end
  end

  def load_tags(db : DB::Database, user : User)
    puts "Loading tags"
    tags = [] of NamedTuple(name: String, description: String?, external_id: String)

    sql = <<-SQL
      SELECT DISTINCT
        name,
        description
      FROM groups
      WHERE name IS NOT NULL
    SQL

    db.query(sql) do |results|
      results.each do
        name = results.read(String).strip.capitalize
        next if name.empty?

        tags << {
          name:        name,
          description: results.read(String?).try(&.strip),
          external_id: sha256(name),
        }
      end
    end

    db.query("SELECT DISTINCT tags FROM transactions") do |results|
      results.each do
        names = results.read(String?)
        next if names.nil?

        names.split(",").map(&.strip).each do |name|
          name = name.strip.capitalize
          next if name.empty? || TagQuery.new.name(name).first?

          tags << {
            name:        name,
            description: nil,
            external_id: sha256(name),
          }
        end
      end
    end

    tags.each do |tag|
      next if TagQuery.new.owner_id(user.id).name(tag[:name]).first?

      SaveTag.create!(
        name: tag[:name],
        description: tag[:description],
        external_id: tag[:external_id],
        owner: user,
      )
    rescue ex : PQ::PQError
      Log.error(exception: ex) { "Error creating tag #{tag[:name]}" }
    end
  end

  def load_account(db : DB::Database, user : User) : Account
    puts "Loading account"
    account_type = AccountTypeQuery.new.name("Asset").first

    db.query("SELECT name, customSymbol, customCode FROM metadata LIMIT 1") do |results|
      results.each do
        account_name = results.read(String).strip

        currency_symbol = results.read(String).strip
        currency_name = results.read(String).strip
        if currency_name.empty? || currency_symbol.empty?
          raise "Please set a currency code and symbol for this account"
        end

        currency = CurrencyQuery.new.owner_id(user.id).name(currency_name).first?
        if currency.nil?
          currency = SaveCurrency.create!(name: currency_name, symbol: currency_symbol, owner: user)
        end

        account = AccountQuery.new.preload_currency.name(account_name).currency_id(currency.id).first?
        return account if account

        account = SaveAccount.create!(
          name: account_name,
          currency_id: currency.id,
          type_id: account_type.id,
          owner: user,
        )
        return AccountQuery.preload_currency(account)
      rescue ex : PQ::PQError
        Log.error { "Error creating account #{account_name}(#{currency_symbol})" }
        raise ex
      end
    end

    raise "No account found!"
  end

  def load_transactions(db : DB::Database, user : User, account : Account)
    puts "Loading transactions"

    sql = <<-SQL
      SELECT
        tx.id,
        tx.date,
        tx.description,
        tx.type,
        tx.amount,
        tx.tags,
        groups.name AS group_name
      FROM transactions AS tx
      INNER JOIN groups
        ON groups.id = tx.gid
    SQL

    db.query(sql) do |results|
      results.each do
        id = results.read(Int64).to_s
        date = Time.parse_utc(results.read(String), "%m/%d/%Y")
        description = results.read(String)
        type = results.read(Int32) == 0 ? :income : :expense
        amount = results.read(String).to_f64
        tags = results.read(String?).try { |tags| tags.split(",").map(&.strip) } || [] of String
        tags << results.read(String)
        tags = TagQuery.new.name.in(tags.uniq).owner_id(user.id).map(&.id)

        tx = {
          external_id: id,
          amount:      amount,
          account:     account,
          date:        date,
          description: description,
          tags:        tags,
        }

        begin
          if type == :expense
            load_expense(tx, user)
          else
            load_income(tx, user)
          end
        rescue ex : PQ::PQError
          Log.error(exception: ex) { "Failed to load #{type} transaction" }
        end
      end
    end
  end

  alias Tx = NamedTuple(
    external_id: String,
    account: Account,
    date: Time,
    description: String,
    amount: Float64,
    tags: Array(Int64),
  )

  def load_expense(tx : Tx, user : User)
    Log.info { "Loading expense tx ##{tx[:external_id]}" }
    return if TransactionQuery
                .new
                .external_id(tx[:external_id])
                .from_account_id(tx[:account].id)
                .transaction_date(tx[:date])
                .owner_id(user.id)
                .first?

    SaveExpense.create!(
      external_id: tx[:external_id],
      account: tx[:account],
      amount: tx[:amount],
      transaction_date: tx[:date],
      description: tx[:description],
      tags: tx[:tags],
      owner: user,
    )
  end

  def load_income(tx : Tx, user : User)
    Log.info { "Loading income tx ##{tx[:external_id]}" }
    return if TransactionQuery
                .new
                .external_id(tx[:external_id])
                .to_account_id(tx[:account].id)
                .transaction_date(tx[:date])
                .owner_id(user.id)
                .first?

    SaveIncome.create!(
      external_id: tx[:external_id],
      account: tx[:account],
      amount: tx[:amount],
      transaction_date: tx[:date],
      description: tx[:description],
      tags: tx[:tags],
      owner: user,
    )
  end

  private def sha256(string : String) : String
    digest = Digest::SHA256.new
    digest << string.strip.downcase
    digest.hexfinal
  end
end
