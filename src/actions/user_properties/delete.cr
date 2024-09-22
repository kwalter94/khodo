class UserProperties::Delete < BrowserAction
  delete "/user_properties/:user_property_id" do
    user_property = UserPropertyQuery.find(user_property_id)
    DeleteUserProperty.delete(user_property) do |_operation, _deleted|
      flash.success = "Deleted the user_property"
      redirect Index
    end
  end
end
