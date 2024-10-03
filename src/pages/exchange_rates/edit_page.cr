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
      # Edit fields in src/components/exchange_rates/form_fields.cr
      mount ExchangeRates::FormFields, op, currencies: currencies

      submit "Update", class: "btn btn-primary col col-12", data_disable_with: "Updating..."
    end
  end
end
