class Expenses::New < BrowserAction
  param account_id : Int64 # ameba:disable Lint/UselessAssign

  get "/expenses/new/" do
    account = AccountQuery
      .new
      .preload_currency
      .owner_id(current_user.id)
      .preload_ledger
      .find(account_id)

    html NewPage,
      account: account,
      operation: SaveExpense.new(account: account, owner: current_user, transaction_date: Time.local)
  end
end
