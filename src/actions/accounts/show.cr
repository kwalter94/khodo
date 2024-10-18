class Accounts::Show < BrowserAction
  get "/accounts/:account_id" do
    account = AccountQuery
      .new
      .owner_id(current_user.id)
      .preload_type
      .preload_currency
      .find(account_id)

    account_balance = CumulativeAccountBalanceReportQuery
      .new
      .owner_id(current_user.id)
      .account_id(account.id)
      .currency_id(account.currency_id)
      .period(1)
      .first

    transactions = TransactionQuery
      .new
      .preload_from_account { |account_query| account_query.preload_type.preload_currency }
      .preload_to_account { |account_query| account_query.preload_type.preload_currency }
      .preload_tags
      .owner_id(current_user.id)
      .to_account_id(account.id)
      .or(&.from_account_id(account.id))
      .transaction_date.desc_order

    pages, transactions = paginate(transactions, per_page: 10)

    html ShowPage,
      account: account,
      pages: pages,
      balance: account_balance,
      transactions: transactions
  end
end
