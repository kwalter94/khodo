class UserProperties::Update < BrowserAction
  put "/user_properties" do
    user_properties = UserPropertiesQuery.new.user_id(current_user.id).first

    SaveUserProperties.update(user_properties, params, user: current_user) do |operation, updated_user_properties|
      if operation.saved?
        flash.success = "Properties updated"
      else
        flash.failure = "It looks like the form is not valid"
      end

      html EditPage,
        operation: operation,
        user_properties: updated_user_properties,
        currencies: CurrencyQuery.new.owner_id(current_user.id)
    end
  end
end
