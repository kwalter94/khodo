class Currencies::EditPage < MainLayout
  needs operation : SaveCurrency
  needs currency : Currency
  quick_def page_title, "Edit Currency with id: #{currency.id}"

  def content
    div class: "row" { h1 "Edit Currency \"#{currency.name}\"" }
    div class: "row" { render_currency_form }
  end

  def render_currency_form
    form_for Currencies::Update.with(currency.id) do
      # Edit fields in src/components/currencies/form_fields.cr
      mount Currencies::FormFields, operation

      div class: "d-grid" { submit "Update", data_disable_with: "Updating...", class: "btn btn-primary" }
    end
  end
end
