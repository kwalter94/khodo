class ExchangeRates::EditPage < MainLayout
  needs operation : SaveExchangeRate
  needs exchange_rate : ExchangeRate
  needs currencies : Enumerable(Currency)

  quick_def page_title, "Edit ExchangeRate with id: #{exchange_rate.id}"

  def content
    link "Back to all ExchangeRates", ExchangeRates::Index
    h1 "Edit ExchangeRate with id: #{exchange_rate.id}"
    render_exchange_rate_form(operation)
  end

  def render_exchange_rate_form(op)
    form_for ExchangeRates::Update.with(exchange_rate.id) do
      mount ExchangeRates::FormFields, op, currencies: currencies

      mount Shared::SubmitButton, "Update", data_disable_with: "Updating Exchange Rate..."
    end
  end
end
