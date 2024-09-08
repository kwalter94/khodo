class CreateTransactions::V20240907174202 < Avram::Migrator::Migration::V1
  def migrate
    # Learn about migrations at: https://luckyframework.org/guides/database/migrations
    create table_for(Transaction) do
      primary_key id : Int64
      add description : String, index: true
      add from_amount : Float64, precision: 12, scale: 2
      add to_amount : Float64, precision: 12, scale: 2
      add transaction_date : Time, index: true

      add_belongs_to from_account : Account, on_delete: :restrict
      add_belongs_to to_account : Account, on_delete: :restrict
      add_belongs_to owner : User, on_delete: :cascade

      add_timestamps
    end
  end

  def rollback
    drop table_for(Transaction)
  end
end
