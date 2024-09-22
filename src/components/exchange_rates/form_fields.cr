class ExchangeRates::FormFields < BaseComponent
  needs operation : SaveExchangeRate

  def render
    mount Shared::Field, operation.from_currency_id, &.text_input(autofocus: "true")
    mount Shared::Field, operation.to_currency_id
    mount Shared::Field, operation.rate
  end
end
