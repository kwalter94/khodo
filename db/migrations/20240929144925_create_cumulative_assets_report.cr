class CreateCummulativeAssetsReport::V20240929144925 < Avram::Migrator::Migration::V1
  def migrate
    execute <<-SQL
      CREATE OR REPLACE VIEW cumulative_assets_report AS
      WITH months AS (
        SELECT
          TO_CHAR(date, 'YYYY-MM') AS month
        FROM generate_series(
          COALESCE(
            (SELECT DATE_TRUNC('month', MIN(transaction_date))::DATE FROM transactions),
            CURRENT_DATE - INTERVAL '1 year'
          ),
          CURRENT_DATE,
          '1 month'
        ) AS date
      ),
      asset_receipts AS (
        SELECT
          accounts.owner_id,
          accounts.id AS account_id,
          accounts.name AS account_name,
          currencies.id AS currency_id,
          months.month,
          SUM(transactions.to_amount) AS receipts,
          SUM(SUM(transactions.to_amount)) OVER (
            PARTITION BY currencies.id, accounts.id
            ORDER BY months.month
          ) AS cumulative_receipts
        FROM months
        LEFT JOIN accounts
          ON 1 = 1
        LEFT JOIN transactions
          ON TO_CHAR(transactions.transaction_date, 'YYYY-MM') = months.month
          AND transactions.to_account_id = accounts.id
        INNER JOIN account_types
          ON account_types.id = accounts.type_id
          AND account_types.name ILIKE 'Asset'
        INNER JOIN currencies
          ON currencies.id = accounts.currency_id
        GROUP BY
          accounts.owner_id,
          accounts.id,
          accounts.name,
          currencies.id,
          months.month
      ),
      asset_deductions AS (
        SELECT
          accounts.owner_id,
          accounts.id AS account_id,
          currencies.id AS currency_id,
          months.month,
          SUM(transactions.from_amount) AS deductions,
          SUM(SUM(transactions.from_amount)) OVER (
            PARTITION BY currencies.id, accounts.id
            ORDER BY months.month
          ) AS cumulative_deductions
        FROM months
        LEFT JOIN accounts
          ON 1 = 1
        LEFT JOIN transactions
          ON TO_CHAR(transactions.transaction_date, 'YYYY-MM') = months.month
          AND transactions.from_account_id = accounts.id
        INNER JOIN account_types
          ON account_types.id = accounts.type_id
          AND account_types.name ILIKE 'Asset'
        INNER JOIN currencies
          ON currencies.id = accounts.currency_id
        GROUP BY
          accounts.owner_id,
          accounts.id,
          currencies.id,
          months.month
      ),
      assets AS (
        SELECT
          asset_receipts.month,
          asset_receipts.account_name,
          currencies.name AS currency_name,
          currencies.symbol AS currency_symbol,
          COALESCE(asset_receipts.receipts, 0) AS receipts,
          COALESCE(asset_deductions.deductions, 0) AS deductions,
          COALESCE(asset_receipts.receipts, 0) - COALESCE(asset_deductions.deductions, 0) AS net_receipts,
          COALESCE(asset_receipts.cumulative_receipts, 0) AS cumulative_receipts,
          COALESCE(asset_deductions.cumulative_deductions, 0) AS cumulative_deductions,
          COALESCE(asset_receipts.cumulative_receipts, 0) - COALESCE(asset_deductions.cumulative_deductions, 0) AS total_assets,
          asset_receipts.account_id,
          asset_receipts.currency_id,
          asset_receipts.owner_id
        FROM currencies
        LEFT JOIN asset_receipts
          ON asset_receipts.currency_id = currencies.id
          AND asset_receipts.owner_id = currencies.owner_id
        LEFT JOIN asset_deductions
          ON asset_deductions.currency_id = currencies.id
          AND asset_deductions.month = asset_receipts.month
          AND asset_deductions.owner_id = asset_receipts.owner_id
          AND asset_deductions.account_id = asset_receipts.account_id
      )
      SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY account_id ORDER BY month DESC) AS period
      FROM assets
    SQL
  end

  def rollback
    execute "DROP VIEW cumulative_assets_report"
  end
end
