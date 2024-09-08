class Currencies::Show < BrowserAction
  get "/currencies/:currency_id" do
    html ShowPage, currency: CurrencyQuery.new.owner_id(current_user.id).find(currency_id)
  end
end
