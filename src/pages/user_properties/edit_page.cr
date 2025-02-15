class UserProperties::EditPage < MainLayout
  needs operation : SaveUserProperties    # ameba:disable Lint/UselessAssign
  needs user_properties : UserProperties  # ameba:disable Lint/UselessAssign
  needs currencies : Enumerable(Currency) # ameba:disable Lint/UselessAssign

  quick_def page_title, "Edit Properties"

  def content
    div class: "row" { h1 "Properties" }
    div class: "row" { render_user_property_form }
  end

  def render_user_property_form
    form_for UserProperties::Update do
      mount UserProperties::FormFields, operation: operation, currencies: currencies
      mount Shared::SubmitButton, label: "Save", data_disable_with: "Updating Properties"
    end
  end
end
