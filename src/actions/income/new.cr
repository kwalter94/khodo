class Income::New < BrowserAction
  param account_id : Int64

  get "/income/new/" do
    account = AccountQuery
      .new
      .preload_currency
      .owner_id(current_user.id)
      .find(account_id)

    html NewPage,
      operation: SaveIncome.new(account: account, owner: current_user)
  end
end
