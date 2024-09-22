class UserProperties::FormFields < BaseComponent
  needs operation : SaveUserProperty

  def render
    mount Shared::Field, operation.currency_id, &.text_input(autofocus: "true")
  end
end
