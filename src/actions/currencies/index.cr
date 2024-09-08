class Currencies::Index < BrowserAction
  get "/currencies" do
    html IndexPage, currencies: CurrencyQuery.new.owner_id(current_user.id)
  end
end
