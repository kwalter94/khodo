class CreateExchangeRateMatrix::V20241003150135 < Avram::Migrator::Migration::V1
  def migrate
    execute <<-SQL
      CREATE VIEW exchange_rate_matrix AS
      SELECT
        source_currency.owner_id,
        source_currency.id AS to_currency_id,
        source_currency.name AS to_currency_name,
        source_currency.symbol AS to_currency_symbol,
        target_currency.id AS from_currency_id,
        target_currency.name AS from_currency_name,
        target_currency.symbol AS from_currency_symbol,
        CASE
          WHEN target_currency.id = source_currency.id THEN 1.0
          WHEN exchange_rates.from_currency_id = source_currency.id THEN 1 / exchange_rates.rate
          WHEN exchange_rates.to_currency_id = source_currency.id THEN exchange_rates.rate
          ELSE NULL
        END AS rate
      FROM currencies AS source_currency
      LEFT JOIN currencies AS target_currency
        ON target_currency.owner_id = source_currency.owner_id
      LEFT JOIN exchange_rates
        ON (
          exchange_rates.from_currency_id = source_currency.id
          AND exchange_rates.to_currency_id = target_currency.id
        ) OR (
          exchange_rates.to_currency_id = source_currency.id
          AND exchange_rates.from_currency_id = target_currency.id
        )
    SQL
  end

  def rollback
    execute "DROP VIEW exchange_rate_matrix"
  end
end
