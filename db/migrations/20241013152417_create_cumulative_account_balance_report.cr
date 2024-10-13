class CreateCumulativeAccountBalanceReport::V20241013152417 < Avram::Migrator::Migration::V1
  def migrate
    execute "DROP VIEW cumulative_assets_report"

    execute <<-SQL
      CREATE VIEW cumulative_account_balance_report AS
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
      account_receipts AS (
        SELECT
          accounts.owner_id,
          accounts.id AS account_id,
          accounts.name AS account_name,
          account_types.id AS account_type_id,
          account_types.name AS account_type_name,
          exchange_rate.to_currency_id AS currency_id,
          exchange_rate.to_currency_name AS currency_name,
          exchange_rate.to_currency_symbol AS currency_symbol,
          months.month,
          SUM(transactions.to_amount * exchange_rate.rate) AS receipts,
          SUM(SUM(transactions.to_amount * exchange_rate.rate)) OVER (
            PARTITION BY exchange_rate.to_currency_id, accounts.id
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
          AND account_types.name IN ('Asset', 'Liability')
        LEFT JOIN exchange_rate_matrix AS exchange_rate
          ON exchange_rate.from_currency_id = accounts.currency_id
        GROUP BY
          accounts.owner_id,
          accounts.id,
          accounts.name,
          account_types.id,
          account_types.name,
          exchange_rate.to_currency_id,
          exchange_rate.to_currency_name,
          exchange_rate.to_currency_symbol,
          months.month
      ),
      account_deductions AS (
        SELECT
          accounts.owner_id,
          accounts.id AS account_id,
          exchange_rate.to_currency_id AS currency_id,
          exchange_rate.to_currency_name AS currency_name,
          exchange_rate.to_currency_symbol AS currency_symbol,
          months.month,
          SUM(transactions.from_amount * exchange_rate.rate) AS deductions,
          SUM(SUM(transactions.from_amount * exchange_rate.rate)) OVER (
            PARTITION BY exchange_rate.to_currency_id, accounts.id
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
          AND account_types.name IN ('Asset', 'Liability')
        LEFT JOIN exchange_rate_matrix AS exchange_rate
          ON exchange_rate.from_currency_id = accounts.currency_id
        GROUP BY
          accounts.owner_id,
          accounts.id,
          exchange_rate.to_currency_id,
          exchange_rate.to_currency_name,
          exchange_rate.to_currency_symbol,
          months.month
      ),
      account_balances AS (
        SELECT
          account_receipts.month,
          account_receipts.account_name,
          account_receipts.account_type_name,
          account_receipts.currency_name,
          account_receipts.currency_symbol,
          COALESCE(account_receipts.receipts, 0) AS receipts,
          COALESCE(account_deductions.deductions, 0) AS deductions,
          COALESCE(account_receipts.receipts, 0) - COALESCE(account_deductions.deductions, 0) AS net_receipts,
          COALESCE(account_receipts.cumulative_receipts, 0) AS cumulative_receipts,
          COALESCE(account_deductions.cumulative_deductions, 0) AS cumulative_deductions,
          COALESCE(account_receipts.cumulative_receipts, 0) - COALESCE(account_deductions.cumulative_deductions, 0) AS balance,
          account_receipts.account_id,
          account_receipts.account_type_id,
          account_receipts.currency_id,
          account_receipts.owner_id
        FROM account_receipts
        LEFT JOIN account_deductions
          ON account_deductions.currency_id = account_receipts.currency_id
          AND account_deductions.month = account_receipts.month
          AND account_deductions.account_id = account_receipts.account_id
          AND account_deductions.owner_id = account_receipts.owner_id
      )
      SELECT
        *,
        ROW_NUMBER() OVER (
          PARTITION BY account_id, currency_id
          ORDER BY month DESC
        ) AS period
      FROM account_balances
    SQL
  end

  def rollback
    execute "DROP VIEW cumulative_account_balance_report"

    execute <<-SQL
      CREATE VIEW cumulative_assets_report AS
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
          exchange_rate.to_currency_id AS currency_id,
          exchange_rate.to_currency_name AS currency_name,
          exchange_rate.to_currency_symbol AS currency_symbol,
          months.month,
          SUM(transactions.to_amount * exchange_rate.rate) AS receipts,
          SUM(SUM(transactions.to_amount * exchange_rate.rate)) OVER (
            PARTITION BY exchange_rate.to_currency_id, accounts.id
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
        LEFT JOIN exchange_rate_matrix AS exchange_rate
          ON exchange_rate.from_currency_id = accounts.currency_id
        GROUP BY
          accounts.owner_id,
          accounts.id,
          accounts.name,
          exchange_rate.to_currency_id,
          exchange_rate.to_currency_name,
          exchange_rate.to_currency_symbol,
          months.month
      ),
      asset_deductions AS (
        SELECT
          accounts.owner_id,
          accounts.id AS account_id,
          exchange_rate.to_currency_id AS currency_id,
          exchange_rate.to_currency_name AS currency_name,
          exchange_rate.to_currency_symbol AS currency_symbol,
          months.month,
          SUM(transactions.from_amount * exchange_rate.rate) AS deductions,
          SUM(SUM(transactions.from_amount * exchange_rate.rate)) OVER (
            PARTITION BY exchange_rate.to_currency_id, accounts.id
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
        LEFT JOIN exchange_rate_matrix AS exchange_rate
          ON exchange_rate.from_currency_id = accounts.currency_id
        GROUP BY
          accounts.owner_id,
          accounts.id,
          exchange_rate.to_currency_id,
          exchange_rate.to_currency_name,
          exchange_rate.to_currency_symbol,
          months.month
      ),
      assets AS (
        SELECT
          asset_receipts.month,
          asset_receipts.account_name,
          asset_receipts.currency_name,
          asset_receipts.currency_symbol,
          COALESCE(asset_receipts.receipts, 0) AS receipts,
          COALESCE(asset_deductions.deductions, 0) AS deductions,
          COALESCE(asset_receipts.receipts, 0) - COALESCE(asset_deductions.deductions, 0) AS net_receipts,
          COALESCE(asset_receipts.cumulative_receipts, 0) AS cumulative_receipts,
          COALESCE(asset_deductions.cumulative_deductions, 0) AS cumulative_deductions,
          COALESCE(asset_receipts.cumulative_receipts, 0) - COALESCE(asset_deductions.cumulative_deductions, 0) AS total_assets,
          asset_receipts.account_id,
          asset_receipts.currency_id,
          asset_receipts.owner_id
        FROM asset_receipts
        LEFT JOIN asset_deductions
          ON asset_deductions.currency_id = asset_receipts.currency_id
          AND asset_deductions.month = asset_receipts.month
          AND asset_deductions.account_id = asset_receipts.account_id
          AND asset_deductions.owner_id = asset_receipts.owner_id
      )
      SELECT
        *,
        ROW_NUMBER() OVER (
          PARTITION BY account_id, currency_id
          ORDER BY month DESC
        ) AS period
      FROM assets
    SQL
  end
end
