class CreateAccountBalanceReport::V20240908184936 < Avram::Migrator::Migration::V1
  def migrate
    execute <<-SQL
      CREATE VIEW account_balance_report AS
        WITH all_time_balance AS (
          SELECT
            accounts.id AS account_id,
            accounts.owner_id,
            accounts.name,
            currencies.name AS currency_name,
            COALESCE(SUM(to_tx.to_amount), 0) - COALESCE(SUM(from_tx.from_amount), 0) AS balance
          FROM accounts
          INNER JOIN currencies
            ON currencies.id = accounts.currency_id
          LEFT JOIN transactions AS from_tx
            ON from_tx.from_account_id = accounts.id
          LEFT JOIN transactions AS to_tx
            ON to_tx.to_account_id = accounts.id
          GROUP BY
            accounts.id,
            accounts.owner_id,
            accounts.name,
            currencies.name
        ),
        last_month_balance AS (
          SELECT
            accounts.id AS account_id,
            COALESCE(SUM(to_tx.to_amount), 0) AS total_additions,
            COALESCE(SUM(from_tx.from_amount), 0) AS total_deductions
          FROM accounts
          LEFT JOIN transactions AS from_tx
            ON from_tx.from_account_id = accounts.id
            AND from_tx.transaction_date >= CURRENT_DATE - INTERVAL '1 month'
          LEFT JOIN transactions AS to_tx
            ON to_tx.to_account_id = accounts.id
            AND to_tx.transaction_date >= CURRENT_DATE - INTERVAL '1 month'
          GROUP BY
            accounts.id
        )
        SELECT
          all_time_balance.account_id,
          all_time_balance.owner_id,
          all_time_balance.name,
          all_time_balance.currency_name,
          last_month_balance.total_additions AS total_additions_last_month,
          last_month_balance.total_deductions AS total_deductions_last_month,
          last_month_balance.total_additions - last_month_balance.total_deductions AS net_additions_last_month,
          all_time_balance.balance
        FROM all_time_balance
        INNER JOIN last_month_balance
          ON last_month_balance.account_id = all_time_balance.account_id
    SQL
  end

  def rollback
    execute "DROP VIEW account_balance_report"
  end
end
