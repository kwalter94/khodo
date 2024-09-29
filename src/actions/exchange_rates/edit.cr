class ExchangeRates::Edit < BrowserAction
  get "/exchange_rates/:exchange_rate_id/edit" do
    exchange_rate = ExchangeRateQuery.find(exchange_rate_id)
    currencies = CurrencyQuery.new.owner_id(current_user.id)

    html EditPage,
      operation: SaveExchangeRate.new(exchange_rate, owner: current_user),
      exchange_rate: exchange_rate,
      currencies: currencies
  end
end
