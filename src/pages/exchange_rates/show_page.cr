class ExchangeRates::ShowPage < MainLayout
  needs exchange_rate : ExchangeRate
  quick_def page_title, "ExchangeRate with id: #{exchange_rate.id}"

  def content
    link "Back to all ExchangeRates", ExchangeRates::Index
    h1 "ExchangeRate with id: #{exchange_rate.id}"
    render_actions
    render_exchange_rate_fields
  end

  def render_actions
    section do
      link "Edit", ExchangeRates::Edit.with(exchange_rate.id)
      text " | "
      link "Delete",
        ExchangeRates::Delete.with(exchange_rate.id),
        data_confirm: "Are you sure?"
    end
  end

  def render_exchange_rate_fields
    ul do
      li do
        text "from_currency_id: "
        strong exchange_rate.from_currency_id.to_s
      end
      li do
        text "to_currency_id: "
        strong exchange_rate.to_currency_id.to_s
      end
      li do
        text "rate: "
        strong exchange_rate.rate.to_s
      end
    end
  end
end
