class DropLocalisedCumulativeAssetReport::V20241003183152 < Avram::Migrator::Migration::V1
  def migrate
    execute "DROP VIEW localised_cumulative_assets_report"
  end

  def rollback
    execute <<-SQL
      CREATE OR REPLACE VIEW localised_cumulative_assets_report AS
      WITH default_currency AS (
        SELECT
          currencies.id AS currency_id,
          currencies.name AS currency_name,
          currencies.symbol AS currency_symbol,
          currencies.owner_id
        FROM currencies
        INNER JOIN user_properties
          ON user_properties.currency_id = currencies.id
          AND user_properties.user_id  = currencies.owner_id
      ),
      exchange_rates AS (
        SELECT
          default_currency.owner_id,
          default_currency.currency_id AS to_currency_id,
          default_currency.currency_name AS to_currency_name,
          default_currency.currency_symbol AS to_currency_symbol,
          currencies.id AS from_currency_id,
          currencies.name AS from_currency_name,
          currencies.symbol AS from_currency_symbol,
          CASE
            WHEN currencies.id = default_currency.currency_id THEN 1.0
            WHEN exchange_rates.from_currency_id = default_currency.currency_id THEN 1 / exchange_rates.rate
            WHEN exchange_rates.to_currency_id = default_currency.currency_id THEN exchange_rates.rate
            ELSE NULL
          END AS rate
        FROM default_currency
        LEFT JOIN currencies
          ON currencies.owner_id = default_currency.owner_id
        LEFT JOIN exchange_rates
          ON (
            exchange_rates.from_currency_id = default_currency.currency_id
            AND exchange_rates.to_currency_id = currencies.id
          ) OR (
            exchange_rates.to_currency_id = default_currency.currency_id
            AND exchange_rates.from_currency_id = currencies.id
          )
      ),
      assets AS (
        SELECT
          cumulative_assets_report.month,
          cumulative_assets_report.account_name,
          exchange_rates.to_currency_name AS currency_name,
          exchange_rates.to_currency_symbol AS currency_symbol,
          cumulative_assets_report.receipts * exchange_rates.rate AS receipts,
          cumulative_assets_report.deductions * exchange_rates.rate AS deductions,
          cumulative_assets_report.net_receipts * exchange_rates.rate AS net_receipts,
          cumulative_assets_report.cumulative_receipts * exchange_rates.rate AS cumulative_receipts,
          cumulative_assets_report.cumulative_deductions * exchange_rates.rate AS cumulative_deductions,
          cumulative_assets_report.total_assets * exchange_rates.rate AS total_assets,
          cumulative_assets_report.account_id,
          exchange_rates.to_currency_id AS currency_id,
          cumulative_assets_report.owner_id
        FROM cumulative_assets_report
        LEFT JOIN exchange_rates
          ON exchange_rates.from_currency_id = cumulative_assets_report.currency_id
      )
      SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY account_id ORDER BY month DESC) AS period
      FROM assets

    SQL
  end
end
