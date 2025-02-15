class ExchangeRates::IndexPage < MainLayout
  needs exchange_rates : ExchangeRateQuery
  quick_def page_title, "All ExchangeRates"

  def content
    div class: "row" do
      h3 class: "col col-12 col-md-9" { text "Exchange Rates" }
      div class: "d-grid col col-12 col-md-3" do
        link "New Rate", to: ExchangeRates::New, class: "btn btn-primary"
      end
    end

    div class: "row" { render_exchange_rates }
  end

  def render_exchange_rates
    div class: "table-responsive" do
      table class: "table table-striped" do
        thead do
          th { text "ID" }
          th { text "From Currency" }
          th { text "To Currency" }
          th { text "Rate" }
          th { text "Actions" }
        end

        tbody do
          exchange_rates.each do |exchange_rate|
            tr do
              td { text exchange_rate.id }
              td { text "#{exchange_rate.from_currency.name} (#{exchange_rate.from_currency.symbol})" }
              td { text "#{exchange_rate.to_currency.name} (#{exchange_rate.to_currency.symbol})" }
              td { text "#{format_money(exchange_rate.rate)}" }
              td do
                span class: "btn-group", role: "group", aria_label: "actions" do
                  link "Edit", to: ExchangeRates::Edit.with(exchange_rate.id), class: "btn btn-primary"
                  link "Delete", to: ExchangeRates::Delete.with(exchange_rate.id), data_confirm: "Are you sure?", class: "btn btn-danger"
                end
              end
            end
          end
        end
      end
    end
  end
end
