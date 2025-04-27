class Accounts::IndexPage < MainLayout
  needs report : Reports::AccountBalanceQuery  # ameba:disable Lint/UselessAssign
  needs currencies : Enumerable(Currency)      # ameba:disable Lint/UselessAssign
  needs reporting_currency : Currency          # ameba:disable Lint/UselessAssign
  needs exchange_rates : Hash(Int64, Float64?) # ameba:disable Lint/UselessAssign
  needs ledger : Ledger                        # ameba:disable Lint/UselessAssign

  quick_def page_title, "#{ledger.name} Accounts"

  def content
    div class: "row" do
      h3 class: "col col-12 col-md-8" do
        text "#{ledger.name} Accounts"
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
            th { text "Net Additions (this year)" }
            th { text "Balance" }
          end

          tbody do
            report.each do |balance|
              tr do
                rate = exchange_rates.[balance.currency_id]?

                td { link balance.account_name, Accounts::Show.with(balance.account_id) }
                td { text balance.account_type_name }
                td class: "monetary-value" do
                  text rate.nil? ? "???" : format_money(balance.current_month_net_additions.to_f64 * rate, reporting_currency)
                end
                td class: "monetary-value" do
                  text rate.nil? ? "???" : format_money(balance.current_year_net_additions.to_f64 * rate, reporting_currency)
                end
                td class: "monetary-value" do
                  text rate.nil? ? "???" : format_money(balance.balance.to_f64 * rate, reporting_currency)
                end
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
