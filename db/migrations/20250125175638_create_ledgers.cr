class CreateLedgers::V20250125175638 < Avram::Migrator::Migration::V1
  def migrate
    # Learn about migrations at: https://luckyframework.org/guides/database/migrations
    create table_for(Ledger) do
      primary_key id : Int64 # ameba:disable Lint/UselessAssign
      add_timestamps
      add name : String        # ameba:disable Lint/UselessAssign
      add description : String # ameba:disable Lint/UselessAssign

      add_belongs_to owner : User, on_delete: :cascade # ameba:disable Lint/UselessAssign
    end
  end

  def rollback
    drop table_for(Ledger)
  end
end
