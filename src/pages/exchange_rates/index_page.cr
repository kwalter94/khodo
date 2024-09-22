class ExchangeRates::IndexPage < MainLayout
  needs exchange_rates : ExchangeRateQuery
  quick_def page_title, "All ExchangeRates"

  def content
    h1 "All ExchangeRates"
    link "New ExchangeRate", to: ExchangeRates::New
    render_exchange_rates
  end

  def render_exchange_rates
    ul do
      exchange_rates.each do |exchange_rate|
        li do
          link exchange_rate.from_currency_id, ExchangeRates::Show.with(exchange_rate)
        end
      end
    end
  end
end
