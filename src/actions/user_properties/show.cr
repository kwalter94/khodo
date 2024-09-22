class UserProperties::Show < BrowserAction
  get "/user_properties/:user_property_id" do
    html ShowPage, user_property: UserPropertyQuery.find(user_property_id)
  end
end
