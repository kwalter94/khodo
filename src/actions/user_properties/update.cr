class UserProperties::Update < BrowserAction
  put "/user_properties/:user_property_id" do
    user_property = UserPropertyQuery.find(user_property_id)
    SaveUserProperty.update(user_property, params) do |operation, updated_user_property|
      if operation.saved?
        flash.success = "The record has been updated"
        redirect Show.with(updated_user_property.id)
      else
        flash.failure = "It looks like the form is not valid"
        html EditPage, operation: operation, user_property: updated_user_property
      end
    end
  end
end
