class ExchangeRates::Update < BrowserAction
  put "/exchange_rates/:exchange_rate_id" do
    exchange_rate = ExchangeRateQuery.find(exchange_rate_id)
    currencies = CurrencyQuery.new.owner_id(current_user.id)

    SaveExchangeRate.update(exchange_rate, params, owner: current_user) do |operation, updated_exchange_rate|
      if operation.saved?
        flash.success = "The record has been updated"
        redirect Index
      else
        flash.failure = "It looks like the form is not valid"
        html EditPage,
          operation: operation,
          exchange_rate: updated_exchange_rate,
          currencies: currencies
      end
    end
  end
end
