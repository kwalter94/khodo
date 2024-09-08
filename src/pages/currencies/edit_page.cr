class Currencies::EditPage < MainLayout
  needs operation : SaveCurrency
  needs currency : Currency
  quick_def page_title, "Edit Currency with id: #{currency.id}"

  def content
    link "Back to all Currencies", Currencies::Index
    h1 "Edit Currency with id: #{currency.id}"
    render_currency_form(operation)
  end

  def render_currency_form(op)
    form_for Currencies::Update.with(currency.id) do
      # Edit fields in src/components/currencies/form_fields.cr
      mount Currencies::FormFields, op

      submit "Update", data_disable_with: "Updating..."
    end
  end
end
