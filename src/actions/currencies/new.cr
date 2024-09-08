class Currencies::New < BrowserAction
  get "/currencies/new" do
    html NewPage, operation: SaveCurrency.new(owner: current_user)
  end
end
