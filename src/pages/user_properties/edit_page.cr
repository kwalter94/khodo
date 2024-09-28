class UserProperties::EditPage < MainLayout
  needs operation : SaveUserProperties
  needs user_properties : UserProperties
  needs currencies : Enumerable(Currency)

  quick_def page_title, "Edit Properties"

  def content
    div class: "row" { h1 "Edit Properties" }
    div class: "row" { render_user_property_form }
  end

  def render_user_property_form
    form_for UserProperties::Update do
      # Edit fields in src/components/user_properties/form_fields.cr
      mount UserProperties::FormFields, operation: operation, currencies: currencies

      submit "Update", class: "btn btn-primary", data_disable_with: "Updating..."
    end
  end
end
