class PopulateAccountBalances::V20250301095320 < Avram::Migrator::Migration::V1
  def migrate
    execute <<-SQL
      WITH deductions AS (
        SELECT
          accounts.id AS account_id,
          SUM(COALESCE(from_transactions.from_amount, 0)) AS lifetime_deductions,
              SUM(COALESCE(from_transactions.from_amount, 0)) FILTER (
                WHERE
                  EXTRACT(YEAR FROM from_transactions.transaction_date) >= EXTRACT(YEAR FROM CURRENT_DATE)
              ) AS current_year_deductions,
              SUM(COALESCE(from_transactions.from_amount, 0)) FILTER (
                WHERE
                  TO_CHAR(from_transactions.transaction_date, 'YYYY-MM') >= TO_CHAR(CURRENT_DATE, 'YYYY-MM')
              ) AS current_month_deductions
          FROM accounts
          LEFT JOIN transactions AS from_transactions
            ON from_transactions.from_account_id = accounts.id
          GROUP BY
            accounts.id
      ),
      additions AS (
        SELECT
          accounts.id AS account_id,
            SUM(COALESCE(to_transactions.to_amount, 0)) AS lifetime_additions,
              SUM(COALESCE(to_transactions.to_amount, 0)) FILTER (
                WHERE
                EXTRACT(YEAR FROM to_transactions.transaction_date) >= EXTRACT(YEAR FROM CURRENT_DATE)
              ) AS current_year_additions,
              SUM(COALESCE(to_transactions.to_amount, 0)) FILTER (
                WHERE
                  TO_CHAR(to_transactions.transaction_date, 'YYYY-MM') >= TO_CHAR(CURRENT_DATE, 'YYYY-MM')
              ) AS current_month_additions
          FROM accounts
          LEFT JOIN transactions AS to_transactions
            ON to_transactions.to_account_id = accounts.id
          GROUP BY
            accounts.id
      ),
      prepared_account_balances AS (
        SELECT
          accounts.id,
          COALESCE(additions.lifetime_additions, 0) AS lifetime_additions,
          COALESCE(deductions.lifetime_deductions, 0) AS lifetime_deductions,
          COALESCE(additions.current_year_additions, 0) AS current_year_additions,
          COALESCE(deductions.current_year_deductions, 0) AS current_year_deductions,
          COALESCE(additions.current_month_additions, 0) AS current_month_additions,
          COALESCE(deductions.current_month_deductions, 0) AS current_month_deductions,
          accounts.owner_id
        FROM accounts
        LEFT JOIN deductions
          ON deductions.account_id = accounts.id
        LEFT JOIN additions
          ON additions.account_id = accounts.id
      )
      INSERT INTO account_balances (
        account_id,
        balance,
        lifetime_additions,
        lifetime_deductions,
        current_year_additions,
        current_year_deductions,
        current_month_additions,
        current_month_deductions,
        owner_id
      )
        SELECT
          id,
          lifetime_additions - lifetime_deductions AS balance,
          lifetime_additions,
          lifetime_deductions,
          current_year_additions,
          current_year_deductions,
          current_month_additions,
          current_month_deductions,
          owner_id
        FROM prepared_account_balances;
    SQL
  end

  def rollback
    execute "TRUNCATE account_balances;"
  end
end
