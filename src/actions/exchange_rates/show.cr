class ExchangeRates::Show < BrowserAction
  get "/exchange_rates/:exchange_rate_id" do
    html ShowPage, exchange_rate: ExchangeRateQuery.find(exchange_rate_id)
  end
end
