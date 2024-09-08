class Currencies::ShowPage < MainLayout
  needs currency : Currency
  quick_def page_title, "Currency with id: #{currency.id}"

  def content
    link "Back to all Currencies", Currencies::Index
    h1 "Currency with id: #{currency.id}"
    render_actions
    render_currency_fields
  end

  def render_actions
    section do
      link "Edit", Currencies::Edit.with(currency.id)
      text " | "
      link "Delete",
        Currencies::Delete.with(currency.id),
        data_confirm: "Are you sure?"
    end
  end

  def render_currency_fields
    ul do
      li do
        text "name: "
        strong currency.name.to_s
      end
      li do
        text "symbol: "
        strong currency.symbol.to_s
      end
    end
  end
end
