class Tags::IndexPage < MainLayout
  needs report : Enumerable(MonthlyTransactionsByTagReport)
  needs reporting_currency : Currency
  needs currencies : Enumerable(Currency)

  quick_def page_title, "All Tags"

  def content
    div class: "row" do
      div class: "col col-10" { h1 "All Tags" }
      div class: "col col-2" { link "New Tag", to: Tags::New, class: "btn btn-primary" }
    end

    div class: "row" { render_tags }
  end

  private def render_tags
    render_currency_selector

    div class: "table-responsive" do
      table class: "table table-striped" do
        thead do
          th { text "Tag" }
          th { text "Income (this month)" }
          th { text "Expenses (this month)" }
          th { text "Net Income (this month)" }
        end

        tbody do
          report.each do |row|
            tr do
              td { link row.tag_name, to: Tags::Show.with(row.tag_id) }
              td { text format_money(row.total_income, reporting_currency) }
              td { text format_money(row.total_expenses, reporting_currency) }
              td { text format_money(row.total_income - row.total_expenses, reporting_currency) }
            end
          end
        end
      end
    end
  end

  private def render_currency_selector
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
end
