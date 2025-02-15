class CreateDefaultUserLedgers::V20250126132950 < Avram::Migrator::Migration::V1
  def migrate
    # Read more on migrations
    # https://www.luckyframework.org/guides/database/migrations
    #
    # create table_for(Thing) do
    #   primary_key id : Int64
    #   add_timestamps
    #
    #   add title : String
    #   add description : String?
    # end

    # Run custom SQL with execute
    #
    # execute "CREATE UNIQUE INDEX things_title_index ON things (title);"
    UserQuery.new.each do |user|
      SignUpUser.create_default_ledgers(user)
    end
  end

  def rollback
    LedgerQuery
      .new
      .name.in(["General", "Creditors", "Debtors"])
      .each { |ledger| DeleteLedger.delete!(ledger) }
  end
end
