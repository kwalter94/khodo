class UserProperties::NewPage < MainLayout
  needs operation : SaveUserProperty
  quick_def page_title, "New UserProperty"

  def content
    h1 "New UserProperty"
    render_user_property_form(operation)
  end

  def render_user_property_form(op)
    form_for UserProperties::Create do
      # Edit fields in src/components/user_properties/form_fields.cr
      mount UserProperties::FormFields, op

      submit "Save", data_disable_with: "Saving..."
    end
  end
end
