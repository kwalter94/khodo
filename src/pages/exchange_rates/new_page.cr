class ExchangeRates::NewPage < MainLayout
  needs operation : SaveExchangeRate
  needs currencies : Enumerable(Currency)
  quick_def page_title, "New ExchangeRate"

  def content
    h1 "New ExchangeRate"
    render_exchange_rate_form(operation)
  end

  def render_exchange_rate_form(op)
    form_for ExchangeRates::Create do
      # Edit fields in src/components/exchange_rates/form_fields.cr
      mount ExchangeRates::FormFields, op, currencies: currencies

      submit "Save", class: "btn btn-primary", data_disable_with: "Saving..."
    end
  end
end
