class Currencies::IndexPage < MainLayout
  needs currencies : CurrencyQuery
  quick_def page_title, "All Currencies"

  def content
    h1 "All Currencies"
    link "New Currency", to: Currencies::New
    render_currencies
  end

  def render_currencies
    ul do
      currencies.each do |currency|
        li do
          link currency.name, Currencies::Show.with(currency)
        end
      end
    end
  end
end
