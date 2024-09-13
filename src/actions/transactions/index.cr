class Transactions::Index < BrowserAction
  get "/transactions" do
    transactions = TransactionQuery
      .new
      .preload_from_account(&.preload_currency)
      .preload_to_account(&.preload_currency)
      .preload_tags
      .owner_id(current_user.id)

    html IndexPage, transactions: transactions
  end
end
