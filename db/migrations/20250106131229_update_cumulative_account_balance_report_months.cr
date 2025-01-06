class UpdateCumulativeAccountBalanceReportMonths::V20250106131229 < Avram::Migrator::Migration::V1
  def migrate
    execute <<-SQL
      CREATE OR REPLACE VIEW cumulative_account_balance_report AS
      WITH account_receipts AS (
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
        FROM user_months AS months
        LEFT JOIN accounts
          ON accounts.owner_id = months.user_id
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
        FROM user_months AS months
        LEFT JOIN accounts
          ON accounts.owner_id = months.user_id
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
    # Do nothing!
  end
end
