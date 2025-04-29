require "./base_report_query"

module Reports
  class AccountBalanceQuery < BaseReportQuery(Reports::AccountBalance)
    filter account_id : Int64 # ameba:disable Lint/UselessAssign
    filter ledger_id : Int64  # ameba:disable Lint/UselessAssign
    filter owner_id : Int64   # ameba:disable Lint/UselessAssign

    def find(account_id : Int64) : Reports::AccountBalance
      query, args = self.account_id(account_id).build_query
      ReportingDatabase.query_one(query, args: args, as: Reports::AccountBalance)
    end

    def find?(account_id : Int64) : Reports::AccountBalance?
      query, args = self.account_id(account_id).build_query
      ReportingDatabase.query_one?(query, args: args, as: Reports::AccountBalance)
    end

    protected def base_sql : String
      <<-SQL
        WITH tx AS (
          SELECT
            *,
            strftime(transaction_date, '%Y-%m') AS month,
            EXTRACT(YEAR FROM transaction_date) AS year
          FROM transactions
        ),
        additions AS (
          SELECT DISTINCT
            to_account_id AS account_id,
            SUM(to_amount)
              OVER (PARTITION BY to_account_id)
              AS lifetime_additions,
            SUM(CASE WHEN tx.month = strftime(CURRENT_DATE, '%Y-%m') THEN to_amount ELSE 0.0 END)
              OVER (PARTITION BY to_account_id)
              AS current_month_additions,
            SUM(CASE WHEN tx.year = EXTRACT(YEAR FROM CURRENT_DATE) THEN to_amount ELSE 0.0 END)
              OVER (PARTITION BY to_account_id)
              AS current_year_additions
          FROM tx
        ),
        deductions AS (
          SELECT DISTINCT
            from_account_id AS account_id,
            SUM(from_amount)
              OVER (PARTITION BY from_account_id)
              AS lifetime_deductions,
            SUM(CASE WHEN tx.month = strftime(CURRENT_DATE, '%Y-%m') THEN from_amount ELSE 0.0 END)
              OVER (PARTITION BY from_account_id)
              AS current_month_deductions,
            SUM(CASE WHEN tx.year = EXTRACT(YEAR FROM CURRENT_DATE) THEN from_amount ELSE 0.0 END)
              OVER (PARTITION BY from_account_id)
              AS current_year_deductions
          FROM tx
        ),
        balance AS (
          SELECT
            *,
            COALESCE(lifetime_additions, 0.0) - COALESCE(lifetime_deductions, 0.0) AS balance,
            COALESCE(current_year_additions, 0.0) - COALESCE(current_year_deductions, 0.0) AS current_year_net_additions,
            COALESCE(current_month_additions, 0.0) - COALESCE(current_month_deductions, 0.0) AS current_month_net_additions
          FROM additions
          LEFT JOIN deductions
            USING (account_id)
        ),
        materialized AS (
          SELECT
            accounts.id AS account_id,
            accounts.name AS account_name,
            currencies.id AS currency_id,
            currencies.name AS currency_name,
            currencies.symbol AS currency_symbol,
            COALESCE(balance.balance, 0.0) AS balance,
            COALESCE(balance.lifetime_additions, 0.0) AS lifetime_additions,
            COALESCE(balance.lifetime_deductions, 0.0) AS lifetime_deductions,
            COALESCE(balance.current_year_net_additions, 0.0) AS current_year_net_additions,
            COALESCE(balance.current_year_additions, 0.0) AS current_year_additions,
            COALESCE(balance.current_year_deductions, 0.0) AS current_year_deductions,
            COALESCE(balance.current_month_net_additions, 0.0) AS current_month_net_additions,
            COALESCE(balance.current_month_additions, 0.0) AS current_month_additions,
            COALESCE(balance.current_month_deductions, 0.0) AS current_month_deductions,
            account_types.id AS account_type_id,
            account_types.name AS account_type_name,
            ledgers.id AS ledger_id,
            ledgers.name AS ledger_name,
            accounts.owner_id
          FROM accounts
          INNER JOIN account_types
            ON account_types.id = accounts.type_id
          INNER JOIN ledgers
            ON ledgers.id = accounts.ledger_id
          INNER JOIN currencies
            ON currencies.id = accounts.currency_id
          LEFT JOIN balance
            ON balance.account_id = accounts.id
          ORDER BY
            accounts.name,
            account_types.name,
            ledgers.name
        )
        SELECT * FROM materialized
      SQL
    end
  end
end
