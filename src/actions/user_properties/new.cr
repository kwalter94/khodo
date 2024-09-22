class UserProperties::New < BrowserAction
  get "/user_properties/new" do
    html NewPage, operation: SaveUserProperty.new
  end
end
