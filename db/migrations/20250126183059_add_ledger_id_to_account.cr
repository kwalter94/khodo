class AddLedgerIdToAccount::V20250126183059 < Avram::Migrator::Migration::V1
  def migrate
    alter table_for(Account) do
      add_belongs_to ledger : Ledger?, on_delete: :cascade # ameba:disable Lint/UselessAssign
    end
  end

  def rollback
    alter table_for(Account) do
      remove_belongs_to :ledger
    end
  end
end
