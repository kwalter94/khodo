class Accounts::New < BrowserAction
  get "/accounts/new" do
    html NewPage, operation: SaveAccount.new(owner: current_user)
  end
end
