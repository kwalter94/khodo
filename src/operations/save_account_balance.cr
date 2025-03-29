class SaveAccountBalance < AccountBalance::SaveOperation
  # To save user provided params to the database, you must permit them
  # https://luckyframework.org/guides/database/saving-records#perma-permitting-columns
  #
  # permit_columns balance, total_expenses, total_income, current_expenses, current_income
  def self.apply_transaction(tx : Transaction)
    account_balances = AppDatabase.query_all(
      "SELECT * FROM account_balances WHERE account_id IN ($1, $2) FOR UPDATE",
      args: [tx.from_account_id, tx.to_account_id],
      as: AccountBalance,
    )

    # TODO: Wrap this in a database transaction when Avram supports it!
    account_balances.each do |account_balance|
      patch = reset_account_balance(account_balance)

      if account_balance.account_id == tx.from_account_id
        patch["balance"] -= tx.from_amount
        patch["lifetime_deductions"] += tx.from_amount
        patch["current_month_deductions"] += tx.from_amount
        patch["current_year_deductions"] += tx.from_amount
      elsif account_balance.account_id == tx.to_account_id
        patch["balance"] += tx.to_amount
        patch["lifetime_additions"] += tx.to_amount
        patch["current_month_additions"] += tx.to_amount
        patch["current_year_additions"] += tx.to_amount
      else
        raise "Attempted to update an account balance that doesn't belong to the tx: #{tx.id}"
      end

      SaveAccountBalance.update!(
        account_balance,
        balance: patch["balance"],
        lifetime_deductions: patch["lifetime_deductions"],
        lifetime_additions: patch["lifetime_additions"],
        current_month_additions: patch["current_month_additions"],
        current_month_deductions: patch["current_month_deductions"],
        current_year_additions: patch["current_year_additions"],
        current_year_deductions: patch["current_year_deductions"],
      )
    end
  end

  def self.reverse_transaction(tx : Transaction)
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
      args: [tx.from_account_id, tx.to_account_id, tx.updated_at],
      as: AccountBalance,
    )

    account_balances.each do |account_balance|
      if account_balance.account_id == tx.from_account_id
        month_update = account_balance.updated_at.month == tx.updated_at.month ? tx.from_amount : 0

        update = {
          balance:                  account_balance.balance + tx.from_amount,
          lifetime_additions:       account_balance.lifetime_additions,
          lifetime_deductions:      account_balance.lifetime_deductions - tx.from_amount,
          current_month_additions:  account_balance.current_month_additions,
          current_month_deductions: account_balance.current_month_deductions - month_update,
          current_year_additions:   account_balance.current_year_additions,
          current_year_deductions:  account_balance.current_year_deductions - tx.from_amount,
        }
      elsif account_balance.account_id == tx.to_account_id
        month_update = account_balance.updated_at.month == tx.updated_at.month ? tx.to_amount : 0

        update = {
          balance:                  account_balance.balance - tx.to_amount,
          lifetime_additions:       account_balance.lifetime_additions - tx.to_amount,
          lifetime_deductions:      account_balance.lifetime_deductions,
          current_month_additions:  account_balance.current_month_additions - month_update,
          current_month_deductions: account_balance.current_month_deductions,
          current_year_additions:   account_balance.current_year_additions - tx.to_amount,
          current_year_deductions:  account_balance.current_year_deductions,
        }
      else
        raise "Attempted to update an account balance that doesn't belong to the tx: #{tx.id}"
      end

      SaveAccountBalance.update!(account_balance, **update)
    end
  end

  def self.reset_account_balance(account_balance : AccountBalance) : Hash(String, Float64)
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
      "balance"                  => account_balance.balance,
      "lifetime_deductions"      => account_balance.lifetime_deductions,
      "lifetime_additions"       => account_balance.lifetime_additions,
      "current_month_additions"  => current_month_additions,
      "current_month_deductions" => current_month_deductions,
      "current_year_additions"   => current_year_additions,
      "current_year_deductions"  => current_year_deductions,
    }
  end
end
