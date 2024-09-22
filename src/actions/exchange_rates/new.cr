class ExchangeRates::New < BrowserAction
  get "/exchange_rates/new" do
    html NewPage, operation: SaveExchangeRate.new
  end
end
