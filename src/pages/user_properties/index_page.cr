class UserProperties::IndexPage < MainLayout
  needs user_properties : UserPropertyQuery
  quick_def page_title, "All UserProperties"

  def content
    h1 "All UserProperties"
    link "New UserProperty", to: UserProperties::New
    render_user_properties
  end

  def render_user_properties
    ul do
      user_properties.each do |user_property|
        li do
          link user_property.currency_id, UserProperties::Show.with(user_property)
        end
      end
    end
  end
end
