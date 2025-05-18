module Reports
  class MonthlyTransactionsByTagQuery < BaseReportQuery(Reports::MonthlyTransactionsByTag)
    filter tag_id : Int64      # ameba:disable Lint/UselessAssign
    filter user_id : Int64     # ameba:disable Lint/UselessAssign
    filter currency_id : Int64 # ameba:disable Lint/UselessAssign
    filter user_id : Int64     # ameba:disable Lint/UselessAssign
    filter period : Int64      # ameba:disable Lint/UselessAssign

    def base_sql : String
      <<-SQL
        WITH RECURSIVE month_series AS (
            SELECT
              TIMESTAMP '2020-01-01' AS month
            UNION ALL
            SELECT
              month + INTERVAL '1 month'
            FROM month_series
            WHERE
              month < CURRENT_DATE
        ),
        user_active_months AS (
          SELECT DISTINCT
            users.id AS user_id,
            COALESCE(tx.transaction_date, CURRENT_TIMESTAMP - INTERVAL '1 year') AS month
          FROM users
          LEFT JOIN transactions AS tx
            ON tx.owner_id = users.id
        ),
        user_months AS (
          SELECT DISTINCT
            user_active_months.user_id,
            STRFTIME(month_series.month, '%Y-%m') AS month
          FROM month_series
          LEFT JOIN user_active_months
            ON STRFTIME(user_active_months.month, '%Y-%m') <= STRFTIME(month_series.month, '%Y-%m')
          WHERE
          	month_series.month < CURRENT_DATE
        ),
        income AS (
          SELECT
            STRFTIME(tx.transaction_date, '%Y-%m') AS month,
            tx.owner_id AS user_id,
            exchange_rate.to_currency_id AS currency_id,
            exchange_rate.to_currency_name AS currency_name,
            exchange_rate.to_currency_symbol AS currency_symbol,
            tags.id AS tag_id,
            tags.name AS tag_name,
            SUM(COALESCE(tx.from_amount * exchange_rate.rate, 0)) AS total_income
          FROM currencies AS reporting_currency
          INNER JOIN tags
            ON tags.owner_id = reporting_currency.owner_id
          INNER JOIN transactions AS tx
            ON tx.owner_id = reporting_currency.owner_id
          INNER JOIN accounts AS from_account
            ON from_account.id = tx.from_account_id
          INNER JOIN account_types AS from_account_type
            ON from_account_type.id = from_account.type_id
            -- AND from_account_type.name = 'Income'
          INNER JOIN transaction_tags AS tx_tags
            ON tx_tags.transaction_id = tx.id
            AND tx_tags.tag_id = tags.id
          INNER JOIN exchange_rate_matrix AS exchange_rate
            ON exchange_rate.owner_id = tx.owner_id
            AND exchange_rate.from_currency_id = from_account.currency_id
            AND exchange_rate.to_currency_id = reporting_currency.id
          INNER JOIN accounts AS to_account
            ON to_account.id = tx.to_account_id
          INNER JOIN account_types AS to_account_type
            ON to_account_type.id = to_account.type_id
            AND to_account_type.name != 'Expense'
          GROUP BY
            STRFTIME(tx.transaction_date, '%Y-%m'),
            tx.owner_id,
            exchange_rate.to_currency_id,
            exchange_rate.to_currency_name,
            exchange_rate.to_currency_symbol,
            tags.id,
            tags.name
        ),
        expenses AS (
          SELECT
            STRFTIME(tx.transaction_date, '%Y-%m') AS month,
            tx.owner_id AS user_id,
            exchange_rate.to_currency_id AS currency_id,
            exchange_rate.to_currency_name AS currency_name,
            exchange_rate.to_currency_symbol AS currency_symbol,
            tags.id AS tag_id,
            tags.name AS tag_name,
            SUM(COALESCE(tx.to_amount * exchange_rate.rate, 0)) AS total_expenses
          FROM currencies AS reporting_currency
          INNER JOIN tags
            ON tags.owner_id = reporting_currency.owner_id
          INNER JOIN transactions AS tx
            ON tx.owner_id = reporting_currency.owner_id
          INNER JOIN accounts AS to_account
            ON to_account.id = tx.to_account_id
          INNER JOIN account_types AS to_account_type
            ON to_account_type.id = to_account.type_id
            -- AND to_account_type.name = 'Expense'
          INNER JOIN transaction_tags AS tx_tags
            ON tx_tags.transaction_id = tx.id
            AND tx_tags.tag_id = tags.id
          INNER JOIN exchange_rate_matrix AS exchange_rate
            ON exchange_rate.owner_id = tx.owner_id
            AND exchange_rate.from_currency_id = to_account.currency_id
            AND exchange_rate.to_currency_id = reporting_currency.id
          INNER JOIN accounts AS from_account
            ON from_account.id = tx.from_account_id
          INNER JOIN account_types AS from_account_type
            ON from_account_type.id = from_account.type_id
            AND from_account_type.name != 'Income'
          GROUP BY
            STRFTIME(tx.transaction_date, '%Y-%m'),
            tx.owner_id,
            exchange_rate.to_currency_id,
            exchange_rate.to_currency_name,
            exchange_rate.to_currency_symbol,
            tags.id,
            tags.name
        ),
        monthly_txs_by_tag AS (
          SELECT
            tags.owner_id AS user_id,
            months.month,
            tags.id AS tag_id,
            tags.name AS tag_name,
            COALESCE(income.total_income, 0) AS total_income,
            COALESCE(expenses.total_expenses, 0) AS total_expenses,
            currencies.id AS currency_id,
            currencies.name AS currency_name,
            currencies.symbol AS currency_symbol,
            ROW_NUMBER() OVER (
              PARTITION BY
                tags.owner_id,
                tags.id,
                currencies.id
              ORDER BY months.month DESC
            ) AS period
          FROM tags
          LEFT JOIN currencies
            ON currencies.owner_id = tags.owner_id
          LEFT JOIN user_months AS months
            ON months.user_id = tags.owner_id
          LEFT JOIN income
            ON income.tag_id = tags.id
            AND income.user_id = tags.owner_id
            AND income.month = months.month
            AND income.currency_id = currencies.id
          LEFT JOIN expenses
            ON expenses.tag_id = tags.id
            AND expenses.user_id = tags.owner_id
            AND expenses.month = months.month
            AND expenses.currency_id = currencies.id
          ORDER BY
          	months.month,
          	currencies.name,
          	tags.name
        ),
        monthly_txs_by_tag_report AS (
          SELECT
            user_id,
            month,
            tag_id,
            tag_name,
            currency_id,
            currency_name,
            currency_symbol,
            total_income,
            total_expenses,
            total_income - total_expenses AS net_income,
            period
          FROM monthly_txs_by_tag
          WHERE
            period <= 12
        )
        SELECT * FROM monthly_txs_by_tag_report
      SQL
    end
  end
end
