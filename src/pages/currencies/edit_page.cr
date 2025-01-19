class Currencies::EditPage < MainLayout
  needs operation : SaveCurrency # ameba:disable Lint/UselessAssign
  needs currency : Currency      # ameba:disable Lint/UselessAssign
  quick_def page_title, "Edit Currency with id: #{currency.id}"

  def content
    mount Shared::BreadCrumb,
      path: [
        {"Currencies", Currencies::Index.route},
        {truncate_text(currency.name), Currencies::Show.with(currency.id)},
        {"Edit", Currencies::New.route},
      ]
    div class: "row" { h1 "Editing Currency \"#{currency.name}\"" }
    div class: "row" { render_currency_form }
  end

  def render_currency_form
    form_for Currencies::Update.with(currency.id) do
      mount Currencies::FormFields, operation

      mount Shared::SubmitButton, "Update", data_disable_with: "Updating Currencies..."
    end
  end
end
