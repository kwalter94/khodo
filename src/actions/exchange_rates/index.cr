class ExchangeRates::Index < BrowserAction
  get "/exchange_rates" do
    rates = ExchangeRateQuery.new
      .preload_from_currency
      .preload_to_currency

    html IndexPage, exchange_rates: rates
  end
end
