class Currencies::NewPage < MainLayout
  needs operation : SaveCurrency # ameba:disable Lint/UselessAssign
  quick_def page_title, "New Currency"

  def content
    mount Shared::BreadCrumb,
      path: [
        {"Currencies", Currencies::Index.route},
        {"New", Currencies::New.route},
      ]
    div class: "row" { h1 "New Currency" }
    div class: "row" { render_currency_form }
  end

  def render_currency_form
    form_for Currencies::Create do
      mount Currencies::FormFields, operation
      mount Shared::SubmitButton, data_disable_with: "Saving Currency"
    end
  end
end
