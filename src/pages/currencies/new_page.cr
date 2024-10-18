class Currencies::NewPage < MainLayout
  needs operation : SaveCurrency
  quick_def page_title, "New Currency"

  def content
    div class: "row" { h1 "New Currency" }
    div class: "row" { render_currency_form }
  end

  def render_currency_form
    form_for Currencies::Create do
      # Edit fields in src/components/currencies/form_fields.cr
      mount Currencies::FormFields, operation

      div class: "d-grid" { submit "Update", data_disable_with: "Updating...", class: "btn btn-primary" }
    end
  end
end
