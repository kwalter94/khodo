class ExchangeRates::Index < BrowserAction
  get "/exchange_rates" do
    html IndexPage, exchange_rates: ExchangeRateQuery.new
  end
end
