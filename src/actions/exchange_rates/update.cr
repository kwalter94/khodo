class ExchangeRates::Update < BrowserAction
  put "/exchange_rates/:exchange_rate_id" do
    exchange_rate = ExchangeRateQuery.find(exchange_rate_id)
    SaveExchangeRate.update(exchange_rate, params) do |operation, updated_exchange_rate|
      if operation.saved?
        flash.success = "The record has been updated"
        redirect Show.with(updated_exchange_rate.id)
      else
        flash.failure = "It looks like the form is not valid"
        html EditPage, operation: operation, exchange_rate: updated_exchange_rate
      end
    end
  end
end
