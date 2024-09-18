class AddExternalIdToTransactions::V20240915175837 < Avram::Migrator::Migration::V1
  def migrate
    alter table_for(Transaction) do
      add external_id : String?
    end
  end

  def rollback
    alter table_for(Transaction) do
      remove :external_id
    end
  end
end
