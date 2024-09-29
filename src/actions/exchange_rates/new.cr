class ExchangeRates::New < BrowserAction
  get "/exchange_rates/new" do
    currencies = CurrencyQuery.new.owner_id(current_user.id)

    html NewPage,
      operation: SaveExchangeRate.new(owner: current_user),
      currencies: currencies
  end
end
