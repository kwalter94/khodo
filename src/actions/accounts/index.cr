class Accounts::Index < BrowserAction
  get "/accounts" do
    query = AccountQuery.new.owner_id(current_user.id)
    html IndexPage, accounts: query
  end
end
