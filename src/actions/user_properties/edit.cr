class UserProperties::Edit < BrowserAction
  get "/user_properties/:user_property_id/edit" do
    user_property = UserPropertyQuery.find(user_property_id)
    html EditPage,
      operation: SaveUserProperty.new(user_property),
      user_property: user_property
  end
end
