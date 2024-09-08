class Currencies::NewPage < MainLayout
  needs operation : SaveCurrency
  quick_def page_title, "New Currency"

  def content
    h1 "New Currency"
    render_currency_form(operation)
  end

  def render_currency_form(op)
    form_for Currencies::Create do
      # Edit fields in src/components/currencies/form_fields.cr
      mount Currencies::FormFields, op

      submit "Save", data_disable_with: "Saving..."
    end
  end
end
