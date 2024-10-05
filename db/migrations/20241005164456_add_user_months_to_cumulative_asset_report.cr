class AddUserMonthsToCumulativeAssetReport::V20241005164456 < Avram::Migrator::Migration::V1
  def migrate
    # Read more on migrations
    # https://www.luckyframework.org/guides/database/migrations
    #
    # create table_for(Thing) do
    #   primary_key id : Int64
    #   add_timestamps
    #
    #   add title : String
    #   add description : String?
    # end

    # Run custom SQL with execute
    #
    # execute "CREATE UNIQUE INDEX things_title_index ON things (title);"
    execute <<-SQL
      CREATE OR REPLACE VIEW cumulative_assets_report AS
      WITH asset_receipts AS (
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
        FROM user_months AS months
        LEFT JOIN accounts
          ON accounts.owner_id = months.user_id
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
        FROM user_months AS months
        LEFT JOIN accounts
          ON accounts.owner_id = months.user_id
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

  def rollback
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
