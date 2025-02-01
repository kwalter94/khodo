class CreateLedgerAccountTypes::V20250125175805 < Avram::Migrator::Migration::V1
  def migrate
    # Learn about migrations at: https://luckyframework.org/guides/database/migrations
    create table_for(LedgerAccountTypes) do
      primary_key id : Int64 # ameba:disable Lint/UselessAssign
      add_timestamps
      add_belongs_to ledger : Ledger, on_delete: :cascade            # ameba:disable Lint/UselessAssign
      add_belongs_to account_type : AccountType, on_delete: :cascade # ameba:disable Lint/UselessAssign
      add_belongs_to owner : User, on_delete: :cascade               # ameba:disable Lint/UselessAssign
    end
  end

  def rollback
    drop table_for(LedgerAccountTypes)
  end
end
