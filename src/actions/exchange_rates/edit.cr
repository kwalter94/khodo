class ExchangeRates::Edit < BrowserAction
  get "/exchange_rates/:exchange_rate_id/edit" do
    exchange_rate = ExchangeRateQuery.find(exchange_rate_id)
    html EditPage,
      operation: SaveExchangeRate.new(exchange_rate),
      exchange_rate: exchange_rate
  end
end
