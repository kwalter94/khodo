class UserProperties::Index < BrowserAction
  get "/user_properties" do
    html IndexPage, user_properties: UserPropertyQuery.new
  end
end
