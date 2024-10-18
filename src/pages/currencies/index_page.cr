class Currencies::IndexPage < MainLayout
  needs currencies : CurrencyQuery
  quick_def page_title, "All Currencies"

  def content
    div class: "row" do
      div class: "col col-12 col-md-9" { h3 "All Currencies" }
      div class: "col col-12 col-md-3" do
        span class: "d-grid" { link "New Currency", to: Currencies::New, class: "btn btn-primary" }
      end
    end
    div class: "row" { render_currencies }
  end

  def render_currencies
    div class: "table-responsive" do
      table class: "table table-striped" do
        thead do
          th { text "Currency" }
          th { text "Symbol" }
          th { text "Actions" }
        end

        tbody do
          currencies.each do |currency|
            tr do
              td { text currency.name }
              td { text currency.symbol }
              td do
                span class: "btn-group", role: "group", aria_label: "actions" do
                  link "Edit", to: Currencies::Edit.with(currency.id), class: "btn btn-primary"
                  link "Delete", to: Currencies::Delete.with(currency.id), data_confirm: "Are you sure?", class: "btn btn-danger"
                end
              end
            end
          end
        end
      end
    end
  end
end
