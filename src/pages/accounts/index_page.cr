class Accounts::IndexPage < MainLayout
  needs account_balance_report : AccountBalanceReportQuery
  quick_def page_title, "All Accounts"

  def content
    div class: "row" do
      h3 class: "col col-8" { text "All Accounts" }
      link "New Account", to: Accounts::New, class: "btn btn-primary col col-2 offset-2"
    end

    div class: "row" { render_report }
  end

  def render_report
    div class: "col col-12" do
      table class: "table table-striped" do
        thead do
          th { text "Account" }
          th { text "Currency" }
          th { text "Net Additions (Last Month)" }
          th { text "Balance" }
        end

        tbody do
          account_balance_report.each do |row|
            tr do
              td { link row.name, Accounts::Show.with(row.account) }
              td { text row.currency_name }
              td { text format_money(row.net_additions_last_month) }
              td { text format_money(row.balance) }
            end
          end
        end
      end
    end
  end
end
