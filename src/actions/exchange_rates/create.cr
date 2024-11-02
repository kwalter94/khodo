class ExchangeRates::Create < BrowserAction
  post "/exchange_rates" do
    SaveExchangeRate.create(params, owner: current_user) do |operation, exchange_rate|
      if exchange_rate
        flash.success = "The record has been saved"
        redirect Index
      else
        flash.failure = "It looks like the form is not valid"
        html NewPage,
          operation: operation,
          currencies: CurrencyQuery.new.owner_id(current_user.id)
      end
    end
  end
end
