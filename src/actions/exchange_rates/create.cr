class ExchangeRates::Create < BrowserAction
  post "/exchange_rates" do
    SaveExchangeRate.create(params) do |operation, exchange_rate|
      if exchange_rate
        flash.success = "The record has been saved"
        redirect Show.with(exchange_rate.id)
      else
        flash.failure = "It looks like the form is not valid"
        html NewPage, operation: operation
      end
    end
  end
end
