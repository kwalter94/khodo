class Home::IndexPage < MainLayout
  record NetWorth,
    value : Float64,
    change : Float64,
    total_assets : Float64,
    new_assets : Float64,
    total_liabilities : Float64,
    new_liabilities : Float64

  needs reporting_currency : Currency     # ameba:disable Lint/UselessAssign
  needs currencies : Enumerable(Currency) # ameba:disable Lint/UselessAssign
  needs net_worth : NetWorth              # ameba:disable Lint/UselessAssign

  def content
    div class: "row" { render_menu }
    div class: "row" { render_net_worth_chart }
    div class: "row" { render_cumulative_accounts_chart }
    div class: "row" { render_savings_chart }
  end

  private def render_menu
    div class: "col col-lg-4 offset-lg-8" do
      div class: "input-group mb-2" do
        span class: "input-group-text" { text "Currency" }
        tag(
          "select",
          class: "form-select form-control",
          aria_label: "Select Currency",
          data_controller: "currency-selector",
          data_action: "currency-selector#onChange",
          data_currency_selector_target: "currencyId",
        ) do
          currencies.each do |currency|
            attrs = currency.id == reporting_currency.id ? [:selected] : [] of Symbol
            option(value: currency.id, attrs: attrs) { text "#{currency.name} (#{currency.symbol})" }
          end
        end
      end
    end
  end

  private def render_net_worth_chart
    div class: "col col-lg-4 col-xl-2 offset-xl-3 col-12" do
      number_card label: "Net Worth", number: net_worth.value, change: net_worth.change, color: "bg-primary"
    end

    div class: "col col-md-4 col-xl-2 col-12" do
      number_card label: "Assets", number: net_worth.total_assets, change: net_worth.new_assets, color: "bg-success"
    end

    div class: "col col-md-4 col-xl-2 col-12" do
      number_card label: "Liabilities", number: net_worth.total_liabilities, change: net_worth.new_liabilities, color: "bg-danger"
    end
  end

  private def render_cumulative_accounts_chart
    div class: "col col-12" do
      h6 "Accounts Growth", class: "text-center"
      div class: "chart", id: "accounts-growth", data_controller: "cumulative-accounts-chart" do
        para "This chart shows the cumulative growth of your accounts over time. It includes all accounts, including those that are not currently active."
      end
    end
  end

  private def render_savings_chart
    div class: "row", data_controller: "savings-chart" do
      div class: "col col-lg-12 col-xl-6" do
        h6 "Income vs Expenses", class: "text-center"
        div class: "chart", id: "income-vs-expenses" do
          para "This chart shows the income and expenses over the last 12 months. It helps you to see if you are spending more than you earn."
        end
      end

      div class: "col-lg-12 col-xl-6" do
        h6 "Average Income vs Average Expenses", class: "text-center"
        div class: "chart", id: "average-income-vs-expenses" do
          para "This chart shows the average income and expenses over the last 12 months. It helps you to see if you are saving enough money each month."
        end
      end
    end
  end

  private def number_card(label : String, number : Float64, change : Float64, color : String)
    div class: "card #{color} text-white", style: "margin: 5px; min-height: 160px" do
      div class: "card-body" do
        h5 class: "card-title" { text format_money(number, reporting_currency) }

        change.try do |delta|
          small class: "card-subtitle text-muted" do
            change_indicator delta
            text format_money(delta.abs, reporting_currency)
            text " from last month"
          end
        end
      end

      div class: "card-footer" { text label }
    end
  end

  private def change_indicator(amount : Float64)
    if amount > 0
      i class: "bi bi-caret-up-fill"
    elsif amount < 0
      i class: "bi bi-caret-down-fill"
    end
  end
end
