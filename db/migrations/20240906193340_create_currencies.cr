class CreateCurrencies::V20240906193340 < Avram::Migrator::Migration::V1
  def migrate
    # Learn about migrations at: https://luckyframework.org/guides/database/migrations
    create table_for(Currency) do
      primary_key id : Int64
      add_timestamps
      add name : String
      add symbol : String
      add_belongs_to owner : User, on_delete: :cascade
    end
  end

  def rollback
    drop table_for(Currency)
  end
end
