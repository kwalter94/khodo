class ExchangeRates::EditPage < MainLayout
  needs operation : SaveExchangeRate      # ameba:disable Lint/UselessAssign
  needs exchange_rate : ExchangeRate      # ameba:disable Lint/UselessAssign
  needs currencies : Enumerable(Currency) # ameba:disable Lint/UselessAssign

  quick_def page_title, "Edit ExchangeRate with id: #{exchange_rate.id}"

  def content
    mount Shared::BreadCrumb,
      path: [
        {"Exchange Rates", ExchangeRates::Index.route},
        {exchange_rate.id.to_s, ExchangeRates::Show.with(exchange_rate.id)},
        {"Edit", ExchangeRates::Edit.with(exchange_rate.id)},
      ]

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
