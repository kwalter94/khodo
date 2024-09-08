class CreateTransactionTags::V20240908120349 < Avram::Migrator::Migration::V1
  def migrate
    # Learn about migrations at: https://luckyframework.org/guides/database/migrations
    create table_for(TransactionTag) do
      primary_key id : Int64
      add_belongs_to transaction : Transaction, on_delete: :cascade
      add_belongs_to tag : Tag, on_delete: :cascade
      add_belongs_to owner : User, on_delete: :cascade

      add_timestamps
    end
  end

  def rollback
    drop table_for(TransactionTag)
  end
end
