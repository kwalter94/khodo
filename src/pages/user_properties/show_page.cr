class UserProperties::ShowPage < MainLayout
  needs user_property : UserProperty
  quick_def page_title, "UserProperty with id: #{user_property.id}"

  def content
    link "Back to all UserProperties", UserProperties::Index
    h1 "UserProperty with id: #{user_property.id}"
    render_actions
    render_user_property_fields
  end

  def render_actions
    section do
      link "Edit", UserProperties::Edit.with(user_property.id)
      text " | "
      link "Delete",
        UserProperties::Delete.with(user_property.id),
        data_confirm: "Are you sure?"
    end
  end

  def render_user_property_fields
    ul do
      li do
        text "currency_id: "
        strong user_property.currency_id.to_s
      end
    end
  end
end
