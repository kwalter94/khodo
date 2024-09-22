class UserProperties::EditPage < MainLayout
  needs operation : SaveUserProperty
  needs user_property : UserProperty
  quick_def page_title, "Edit UserProperty with id: #{user_property.id}"

  def content
    link "Back to all UserProperties", UserProperties::Index
    h1 "Edit UserProperty with id: #{user_property.id}"
    render_user_property_form(operation)
  end

  def render_user_property_form(op)
    form_for UserProperties::Update.with(user_property.id) do
      # Edit fields in src/components/user_properties/form_fields.cr
      mount UserProperties::FormFields, op

      submit "Update", data_disable_with: "Updating..."
    end
  end
end
