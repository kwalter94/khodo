class Tags::IndexPage < MainLayout
  needs report : Enumerable(MonthlyTransactionsByTagReport)
  needs currency : Currency
  quick_def page_title, "All Tags"

  def content
    div class: "row" do
      div class: "col col-10" { h1 "All Tags" }
      div class: "col col-2" { link "New Tag", to: Tags::New, class: "btn btn-primary" }
    end

    div class: "row" { render_tags }
  end

  private def render_tags
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
              td { text format_money(row.total_income, currency) }
              td { text format_money(row.total_expenses, currency) }
              td { text format_money(row.total_income - row.total_expenses, currency) }
            end
          end
        end
      end
    end
  end
end
