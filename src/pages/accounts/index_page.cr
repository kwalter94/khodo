class Accounts::IndexPage < MainLayout
  needs accounts : Enumerable(CumulativeAccountBalanceReport) # ameba:disable Lint/UselessAssign
  needs currencies : Enumerable(Currency)                     # ameba:disable Lint/UselessAssign
  needs reporting_currency : Currency                         # ameba:disable Lint/UselessAssign

  quick_def page_title, "All Accounts"

  def content
    div class: "row" do
      h3 class: "col col-12 col-md-8" do
        text "Accounts"
      end

      div class: "col col-12 col-md-3 offset-md-1" do
        div class: "d-grid gap-2" do
          link "New Account", to: Accounts::New, class: "btn btn-primary"
        end
      end
    end

    div class: "row" do
      render_currency_selector
      render_report
    end
  end

  def render_report
    div class: "col col-12" do
      div class: "table-responsive" do
        table class: "table table-striped" do
          thead do
            th { text "Account" }
            th { text "Type" }
            th { text "Net Additions (this month)" }
            th { text "Balance" }
          end

          tbody do
            accounts.each do |row|
              tr do
                td { link row.account_name, Accounts::Show.with(row.account_id) }
                td { text row.account_type_name }
                td class: "monetary-value" { text format_money(row.net_receipts, reporting_currency) }
                td class: "monetary-value" { text format_money(row.balance, reporting_currency) }
              end
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
