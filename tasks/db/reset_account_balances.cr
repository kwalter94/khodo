class ResetAccountBalances < LuckyTask::Task
  summary "Resets all AccountBalances if in a new month"

  Log = ::Log.for(self)

  def call
    AccountBalanceQuery.new.each do |account_balance|
      Log.info { "Resetting account balance: #{account_balance.account_id}" }
      patch = SaveAccountBalance.create_account_balance_update_patch(account_balance)

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
end
