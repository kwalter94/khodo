class ExchangeRates::NewPage < MainLayout
  needs operation : SaveExchangeRate      # ameba:disable Lint/UselessAssign
  needs currencies : Enumerable(Currency) # ameba:disable Lint/UselessAssign
  quick_def page_title, "New ExchangeRate"

  def content
    mount Shared::BreadCrumb,
      path: [
        {"Exchange Rates", ExchangeRates::Index.route},
        {"New", ExchangeRates::New.route},
      ]
    div class: "row" { h1 "New ExchangeRate" }
    div class: "row" { render_exchange_rate_form }
  end

  def render_exchange_rate_form
    form_for ExchangeRates::Create do
      # Edit fields in src/components/exchange_rates/form_fields.cr
      mount ExchangeRates::FormFields, operation, currencies: currencies
      mount Shared::SubmitButton, data_disable_with: "Saving"
    end
  end
end
