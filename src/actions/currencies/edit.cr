class Currencies::Edit < BrowserAction
  get "/currencies/:currency_id/edit" do
    currency = CurrencyQuery.new.owner_id(current_user.id).find(currency_id)
    html EditPage,
      operation: SaveCurrency.new(currency, owner: current_user),
      currency: currency
  end
end
