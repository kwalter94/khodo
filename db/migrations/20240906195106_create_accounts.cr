class CreateAccounts::V20240906195106 < Avram::Migrator::Migration::V1
  def migrate
    # Learn about migrations at: https://luckyframework.org/guides/database/migrations
    create table_for(Account) do
      primary_key id : Int64
      add_timestamps
      add name : String

      add_belongs_to type : AccountType, on_delete: :restrict
      add_belongs_to currency : Currency, on_delete: :restrict
      add_belongs_to owner : User, on_delete: :cascade
    end
  end

  def rollback
    drop table_for(Account)
  end
end
