class CreateExchangeRates::V20240922164805 < Avram::Migrator::Migration::V1
  def migrate
    # Learn about migrations at: https://luckyframework.org/guides/database/migrations
    create table_for(ExchangeRate) do
      primary_key id : Int64
      add_belongs_to from_currency : Currency, on_delete: :restrict
      add_belongs_to to_currency : Currency, on_delete: :restrict
      add rate : Float64
      add_belongs_to owner : User, on_delete: :cascade

      add_timestamps
    end
  end

  def rollback
    drop table_for(ExchangeRate)
  end
end
