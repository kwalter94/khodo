class CreateAccountBalanceReport::V20240908184936 < Avram::Migrator::Migration::V1
  def migrate
    execute <<-SQL
      CREATE VIEW account_balance_report AS
        WITH all_time_income AS (
          SELECT
            to_account_id AS account_id,
            SUM(COALESCE(to_amount, 0)) AS total_income
          FROM transactions
          GROUP BY to_account_id
        ),
        all_time_expenses AS (
          SELECT
            from_account_id AS account_id,
            SUM(COALESCE(from_amount, 0)) AS total_expenses
          FROM transactions
          GROUP BY from_account_id
        ),
        all_time_balance AS (
          SELECT
            accounts.id AS account_id,
            accounts.owner_id,
            accounts.name,
            currencies.name AS currency_name,
            SUM(COALESCE(all_time_income.total_income, 0)) - SUM(COALESCE(all_time_expenses.total_expenses, 0)) AS balance
          FROM accounts
          INNER JOIN currencies
            ON currencies.id = accounts.currency_id
          LEFT JOIN all_time_expenses
            ON all_time_expenses.account_id = accounts.id
          LEFT JOIN all_time_income
            ON all_time_income.account_id = accounts.id
          GROUP BY
            accounts.id,
            accounts.owner_id,
            accounts.name,
            currencies.name
        ),
        last_month_income AS (
          SELECT
            to_account_id AS account_id,
            SUM(COALESCE(to_amount, 0)) AS total_additions
          FROM transactions
          WHERE transaction_date >= CURRENT_DATE - INTERVAL '1 month'
          GROUP BY to_account_id
        ),
        last_month_expenses AS (
          SELECT
            from_account_id AS account_id,
            SUM(COALESCE(from_amount, 0)) AS total_deductions
          FROM transactions
          WHERE transaction_date >= CURRENT_DATE - INTERVAL '1 month'
          GROUP BY from_account_id
        ),
        last_month_balance AS (
          SELECT DISTINCT
            accounts.id AS account_id,
            COALESCE(last_month_income.total_additions, 0) AS total_additions,
            COALESCE(last_month_expenses.total_deductions, 0) AS total_deductions
          FROM accounts
          LEFT JOIN last_month_income
            ON last_month_income.account_id = accounts.id
          LEFT JOIN last_month_expenses
            ON last_month_expenses.account_id = accounts.id
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
