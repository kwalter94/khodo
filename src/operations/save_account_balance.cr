class SaveAccountBalance < AccountBalance::SaveOperation
  def self.apply_transaction(tx : Transaction::TransactionLike)
    account_balances_query = <<-SQL
      SELECT
        *
      FROM account_balances
      WHERE
        account_id IN ($1, $2)
      FOR UPDATE
    SQL
    account_balances = AppDatabase.query_all(
      account_balances_query,
      args: [tx.from_account_id, tx.to_account_id],
      as: AccountBalance,
    )

    # NOTE: This should be probably be wrapped in a database transaction but we are running
    # single threaded at the end of the day, praise gad!
    account_balances.each do |account_balance|
      patch = create_account_balance_update_patch(account_balance)
      is_current_year_tx = tx.transaction_date.year >= account_balance.updated_at.year
      is_current_month_tx = tx.transaction_date.to_s("%Y-%m") >= account_balance.updated_at.to_s("%Y-%m")

      if account_balance.account_id == tx.from_account_id
        patch["lifetime_deductions"] += tx.from_amount
        patch["current_month_deductions"] += tx.from_amount if is_current_month_tx
        patch["current_year_deductions"] += tx.from_amount if is_current_year_tx
      elsif account_balance.account_id == tx.to_account_id
        patch["lifetime_additions"] += tx.to_amount
        patch["current_month_additions"] += tx.to_amount if is_current_month_tx
        patch["current_year_additions"] += tx.to_amount if is_current_year_tx
      end

      SaveAccountBalance.update!(
        account_balance,
        balance: patch["lifetime_additions"] - patch["lifetime_deductions"],
        lifetime_deductions: patch["lifetime_deductions"],
        lifetime_additions: patch["lifetime_additions"],
        current_month_additions: patch["current_month_additions"],
        current_month_deductions: patch["current_month_deductions"],
        current_year_additions: patch["current_year_additions"],
        current_year_deductions: patch["current_year_deductions"],
      )
    end
  end

  def self.reverse_transaction(tx : Transaction::TransactionLike)
    query = <<-SQL
      SELECT
        *
      FROM account_balances
      WHERE
        account_id IN ($1, $2)
        AND EXTRACT(YEAR FROM updated_at) = EXTRACT(YEAR FROM $3::DATE)
      FOR UPDATE
    SQL
    account_balances = AppDatabase.query_all(
      query,
      args: [tx.from_account_id, tx.to_account_id, tx.transaction_date],
      as: AccountBalance,
    )

    account_balances.each do |account_balance|
      patch = create_account_balance_update_patch(account_balance)
      is_current_year_tx = tx.transaction_date.year >= account_balance.updated_at.year
      is_current_month_tx = tx.transaction_date.to_s("%Y-%m") >= account_balance.updated_at.to_s("%Y-%m")

      if account_balance.account_id == tx.from_account_id
        patch["lifetime_deductions"] -= tx.from_amount
        patch["current_month_deductions"] -= tx.from_amount if is_current_month_tx
        patch["current_year_deductions"] -= tx.from_amount if is_current_year_tx
      elsif account_balance.account_id == tx.to_account_id
        patch["lifetime_additions"] -= tx.to_amount
        patch["current_month_additions"] -= tx.to_amount if is_current_month_tx
        patch["current_year_additions"] -= tx.to_amount if is_current_year_tx
      end

      SaveAccountBalance.update!(
        account_balance,
        balance: patch["lifetime_additions"] - patch["lifetime_deductions"],
        lifetime_deductions: patch["lifetime_deductions"],
        lifetime_additions: patch["lifetime_additions"],
        current_month_additions: patch["current_month_additions"],
        current_month_deductions: patch["current_month_deductions"],
        current_year_additions: patch["current_year_additions"],
        current_year_deductions: patch["current_year_deductions"],
      )
    end
  end

  def self.create_account_balance_update_patch(account_balance : AccountBalance) : Hash(String, Float64)
    current_date = Time.local

    current_year_additions : Float64 = account_balance.current_year_additions
    current_year_deductions : Float64 = account_balance.current_year_deductions
    current_month_additions : Float64 = account_balance.current_month_additions
    current_month_deductions : Float64 = account_balance.current_month_deductions

    if account_balance.updated_at.year < current_date.year
      current_year_additions = 0
      current_year_deductions = 0
    end

    if account_balance.updated_at.month < current_date.month
      current_month_additions = 0
      current_month_deductions = 0
    end

    {
      "lifetime_deductions"      => account_balance.lifetime_deductions,
      "lifetime_additions"       => account_balance.lifetime_additions,
      "current_month_additions"  => current_month_additions,
      "current_month_deductions" => current_month_deductions,
      "current_year_additions"   => current_year_additions,
      "current_year_deductions"  => current_year_deductions,
    }
  end
end
