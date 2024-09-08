class Accounts::Index < BrowserAction
  get "/accounts" do
    query = AccountBalanceReportQuery
      .new
      .owner_id(current_user.id)
      .preload_account

    html IndexPage, account_balance_report: query
  end
end
