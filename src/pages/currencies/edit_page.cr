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
      mount Currencies::FormFields, operation

      mount Shared::SubmitButton, "Update", data_disable_with: "Updating Currencies..."
    end
  end
end
