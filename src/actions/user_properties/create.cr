class UserProperties::Create < BrowserAction
  post "/user_properties" do
    SaveUserProperty.create(params) do |operation, user_property|
      if user_property
        flash.success = "The record has been saved"
        redirect Show.with(user_property.id)
      else
        flash.failure = "It looks like the form is not valid"
        html NewPage, operation: operation
      end
    end
  end
end
