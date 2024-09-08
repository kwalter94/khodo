class Accounts::Show < BrowserAction
  get "/accounts/:account_id" do
    query = AccountQuery
      .new
      .owner_id(current_user.id)
      .preload_type
      .preload_currency
      .find(account_id)
    html ShowPage, account: query
  end
end
