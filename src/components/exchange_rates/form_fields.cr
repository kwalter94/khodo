class ExchangeRates::FormFields < BaseComponent
  needs operation : SaveExchangeRate      # ameba:disable Lint/UselessAssign
  needs currencies : Enumerable(Currency) # ameba:disable Lint/UselessAssign

  def render
    currency_options = currencies.map { |currency| {currency.name, currency.id} }

    mount Shared::Field, operation.from_currency_id do |input|
      input.select_input do
        options_for_select operation.from_currency_id, currency_options
      end
    end

    mount Shared::Field, operation.to_currency_id do |input|
      input.select_input do
        options_for_select operation.to_currency_id, currency_options
      end
    end

    mount Shared::Field, operation.rate do |input|
      input.number_input(min: "0.1", step: "0.01")
    end
  end
end
