class CreateMonthlySavingsReport::V20241005185124 < Avram::Migrator::Migration::V1
  def migrate
    execute <<-SQL
      CREATE VIEW monthly_savings_report AS
        WITH monthly_income AS (
          SELECT
            months.month,
            accounts.currency_id,
            SUM(COALESCE(tx.from_amount, 0)) AS amount,
            accounts.owner_id AS user_id
          FROM user_months AS months
          INNER JOIN accounts
            ON accounts.owner_id = months.user_id
          INNER JOIN account_types
            ON account_types.id = accounts.type_id
            AND account_types.name = 'Income'
          LEFT JOIN transactions AS tx
            ON tx.from_account_id = accounts.id
            AND TO_CHAR(tx.transaction_date, 'YYYY-MM') = months.month
          GROUP BY
            months.month,
            accounts.currency_id,
            accounts.owner_id
        ),
        monthly_expenses AS (
          SELECT
            months.month,
            accounts.currency_id,
            SUM(COALESCE(tx.to_amount, 0)) AS amount,
            accounts.owner_id AS user_id
          FROM user_months AS months
          INNER JOIN accounts
            ON accounts.owner_id = months.user_id
          INNER JOIN account_types
            ON account_types.id = accounts.type_id
            AND account_types.name = 'Expense'
          LEFT JOIN transactions AS tx
            ON tx.to_account_id = accounts.id
            AND TO_CHAR(tx.transaction_date, 'YYYY-MM') = months.month
          GROUP BY
            months.month,
            accounts.currency_id,
            accounts.owner_id
        ),
        monthly_savings AS (
          SELECT
            monthly_income.month,
            currencies.id AS currency_id,
            currencies.name AS currency_name,
            currencies.symbol AS currency_symbol,
            SUM(monthly_income.amount * exchange_rates.rate) AS income,
            SUM(monthly_expenses.amount * exchange_rates.rate) AS expenses,
            monthly_income.user_id
          FROM monthly_income
          LEFT JOIN monthly_expenses
            ON monthly_expenses.month = monthly_income.month
            AND monthly_expenses.currency_id = monthly_income.currency_id
          LEFT JOIN currencies
            ON currencies.owner_id = monthly_income.user_id
          LEFT JOIN exchange_rate_matrix AS exchange_rates
            ON exchange_rates.from_currency_id = monthly_income.currency_id
            AND exchange_rates.to_currency_id = currencies.id
          GROUP BY
            monthly_income.month,
            currencies.id,
            currencies.name,
            monthly_income.user_id
        )
        SELECT
          month,
          currency_id,
          currency_name,
          currency_symbol,
          income,
          expenses,
          income - expenses AS savings,
          user_id,
          ROW_NUMBER() OVER (PARTITION BY currency_id ORDER BY month DESC) AS period
        FROM monthly_savings;
    SQL
  end

  def rollback
    execute "DROP VIEW monthly_savings_report"
  end
end
