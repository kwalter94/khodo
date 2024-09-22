class ExchangeRates::Delete < BrowserAction
  delete "/exchange_rates/:exchange_rate_id" do
    exchange_rate = ExchangeRateQuery.find(exchange_rate_id)
    DeleteExchangeRate.delete(exchange_rate) do |_operation, _deleted|
      flash.success = "Deleted the exchange_rate"
      redirect Index
    end
  end
end
