class Accounts::IndexPage < MainLayout
  needs account_balance_report : AccountBalanceReportQuery
  quick_def page_title, "All Accounts"

  def content
    div class: "row" do
      link "New Account", to: Accounts::New, class: "btn btn-primary col col-2 offset-md-10"
    end

    div class: "row" { render_report }
  end

  def render_report
    div class: "col col-12" do
      table class: "table table-striped table-dark" do
        thead do
          th { text "Account" }
          th { text "Currency" }
          th { text "Additions (Last Month)" }
          th { text "Deductions (Last Month)" }
          th { text "Net Additions (Last Month)" }
          th { text "Balance" }
        end

        tbody do
          account_balance_report.each do |row|
            tr do
              td { link row.name, Accounts::Show.with(row.account) }
              td { text row.currency_name.to_s }
              td { text row.total_additions_last_month.to_s }
              td { text row.total_deductions_last_month.to_s }
              td { text row.net_additions_last_month.to_s }
              td { text row.balance.to_s }
            end
          end
        end
      end
    end
  end
end
