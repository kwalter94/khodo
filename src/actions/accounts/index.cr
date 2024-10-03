class Accounts::Index < BrowserAction
  get "/accounts" do
    asset_accounts = AccountQuery
      .new
      .owner_id(current_user.id)
      .where_type(AccountTypeQuery.new.name.in(["Asset", "Liability"]))

    report = AccountBalanceReportQuery
      .new
      .preload_account
      .owner_id(current_user.id)
      .where_account(asset_accounts)
      .name.asc_order
      .currency_name.asc_order

    html IndexPage, account_balance_report: report
  end
end
