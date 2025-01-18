class LimitUserMonthsToCurrentMonth::V20250118142038 < Avram::Migrator::Migration::V1
  def migrate
    execute <<-SQL
      CREATE OR REPLACE VIEW user_months AS
        WITH months AS (
          SELECT
            TO_CHAR(date, 'YYYY-MM') AS month
          FROM generate_series('2000-01-01'::DATE, CURRENT_DATE, '1 month') AS date
        ),
        user_start_month AS (
          SELECT
            users.id AS user_id,
            TO_CHAR(COALESCE(tx.transaction_date, CURRENT_DATE - INTERVAL '1 Year'), 'YYYY-MM') AS month
          FROM users
          LEFT JOIN transactions AS tx
            ON tx.owner_id = users.id
        )
        SELECT DISTINCT
          months.month,
          user_start_month.user_id
        FROM months
        INNER JOIN user_start_month
          ON user_start_month.month <= months.month;
    SQL
  end

  def rollback
  end
end
