class Home::IndexPage < MainLayout
  needs reporting_currency : Currency     # ameba:disable Lint/UselessAssign
  needs currencies : Enumerable(Currency) # ameba:disable Lint/UselessAssign
  needs total_assets : Float64            # ameba:disable Lint/UselessAssign
  needs new_assets : Float64              # ameba:disable Lint/UselessAssign

  def content
    div class: "row" { render_menu }
    div class: "row" { render_net_worth_cards_section }
    div class: "row", data_controller: "assets-charts" { render_asset_charts_section }
    div class: "row", data_controller: "savings-charts" { render_savings_charts_section }
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

  private def render_net_worth_cards_section
    div class: "col col-md-4 col-12" do
      number_card label: "Net Worth", number: total_assets, change: new_assets, color: "bg-primary"
    end

    div class: "col col-md-4 col-12" do
      number_card label: "Assets", number: total_assets, change: new_assets, color: "bg-success"
    end

    div class: "col col-md-4 col-12" do
      number_card label: "Liabilities", number: 0.0, change: 0.0, color: "bg-danger"
    end
  end

  private def render_asset_charts_section
    # div class: "col col-lg-6 col-12" do
    #   h6 "Asset Distribution", class: "text-center"
    #   empty_tag "canvas", id: "assets-distribution", class: "chart"
    # end

    div class: "col col-12" do
      h6 "Asset Growth", class: "text-center"
      empty_tag "canvas", id: "assets-growth", class: "chart"
    end
  end

  private def render_savings_charts_section
    div class: "col col-lg-6 col-12" do
      h6 "Income vs Expenses", class: "text-center"
      empty_tag "canvas", id: "income-vs-expenses", class: "chart"
    end

    div class: "col col-lg-6 col-12" do
      h6 "Savings", class: "text-center"
      empty_tag "canvas", id: "savings", class: "chart"
    end
  end

  private def number_card(label : String, number : Float64, change : Float64, color : String)
    div class: "card #{color} text-white", style: "margin: 5px; min-height: 160px" do
      div class: "card-body" do
        h5 class: "card-title" { text format_money(number, reporting_currency) }

        small class: "card-subtitle text-muted" do
          change_indicator change
          text format_money(change.abs, reporting_currency)
          text " from last month"
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
