class UserProperties::Edit < BrowserAction
  get "/user_properties" do
    user_properties = UserPropertiesQuery.new.user_id(current_user.id).first
    currencies = CurrencyQuery.new.owner_id(current_user.id)

    html EditPage,
      currencies: currencies,
      operation: SaveUserProperties.new(user_properties, user: current_user),
      user_properties: user_properties
  end
end
