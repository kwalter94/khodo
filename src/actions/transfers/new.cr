class Transfers::New < BrowserAction
  param account_id : Int64

  get "/transfers/new" do
    account = AccountQuery
      .new
      .preload_currency
      .owner_id(current_user.id)
      .find(account_id)

    html NewPage,
      operation: SaveTransaction.new(from_account_id: account.id, owner: current_user),
      account: account
  end
end
