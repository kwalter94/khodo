class Home::IndexPage < MainLayout
  needs currency : Currency
  needs assets_query : LocalisedCumulativeAssetsReportQuery
  needs total_assets : Float64
  needs new_assets : Float64

  def content
    div class: "row" do
      div class: "col-md-3" do
        number_card label: "Net Worth", number: total_assets, change: new_assets, color: "bg-primary"
      end
      div class: "col-md-1 align-self-center" do
        para class: "h1 text-center" { text "=" }
      end
      div class: "col-md-3" do
        number_card label: "Assets", number: total_assets, change: new_assets, color: "bg-success"
      end
      div class: "col-md-1 align-self-center" do
        para class: "h1 text-center" { text "-" }
      end
      div class: "col-md-3" do
        number_card label: "Liabilities", number: 0.0, change: 0.0, color: "bg-danger"
      end
    end
  end

  private def number_card(label : String, number : Float64, change : Float64, color : String)
    div class: "card #{color} text-white" do
      div class: "card-body" do
        h5 class: "card-title" { text format_money(number, currency) }
        small class: "card-subtitle text-muted" do
          change_indicator change
          text format_money(change.abs, currency)
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
