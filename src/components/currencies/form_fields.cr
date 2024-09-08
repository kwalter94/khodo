class Currencies::FormFields < BaseComponent
  needs operation : SaveCurrency

  def render
    mount Shared::Field, operation.name, &.text_input(autofocus: "true")
    mount Shared::Field, operation.symbol
  end
end
