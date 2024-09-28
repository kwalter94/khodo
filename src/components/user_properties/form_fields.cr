class UserProperties::FormFields < BaseComponent
  needs operation : SaveUserProperties
  needs currencies : Enumerable(Currency)

  def render
    mount Shared::Field, operation.currency_id do |html|
      html.select_input do
        options = currencies.map { |currency| {currency.name, currency.id} }
        options_for_select operation.currency_id, options
      end
    end
  end
end
