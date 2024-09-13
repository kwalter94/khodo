class Expenses::New < BrowserAction
  param account_id : Int64

  get "/expenses/new/" do
    account = AccountQuery
      .new
      .preload_currency
      .owner_id(current_user.id)
      .find(account_id)

    html NewPage,
      operation: SaveExpense.new(account: account, owner: current_user)
  end
end
