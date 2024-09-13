class Accounts::Show < BrowserAction
  get "/accounts/:account_id" do
    account = AccountQuery
      .new
      .owner_id(current_user.id)
      .preload_type
      .preload_currency
      .find(account_id)

    account_balance = AccountBalanceReportQuery
      .new
      .owner_id(current_user.id)
      .account_id(account.id)
      .first

    raise "Missing account report" if account_balance.nil?

    start_date = (Time.local - Time::Span.new(days: 30)).to_s("%Y-%m-%d")

    transactions = TransactionQuery
      .new
      .preload_from_account(&.preload_type)
      .preload_to_account(&.preload_type)
      .preload_tags
      .owner_id(current_user.id)
      .to_account_id(account.id)
      .or(&.from_account_id(account.id))
      .transaction_date.gte(start_date)
      .transaction_date.desc_order

    html ShowPage,
      account: account,
      balance: account_balance,
      transactions: transactions
  end
end
