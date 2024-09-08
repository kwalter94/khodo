class Transactions::New < BrowserAction
  get "/transactions/new" do
    html NewPage, operation: SaveTransaction.new(owner: current_user)
  end
end
