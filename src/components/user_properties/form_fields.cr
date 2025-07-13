class UserProperties::FormFields < BaseComponent
  needs operation : SaveUserProperties    # ameba:disable Lint/UselessAssign
  needs currencies : Enumerable(Currency) # ameba:disable Lint/UselessAssign

  def render
    mount Shared::Field, operation.currency_id do |html|
      html.select_input do
        options = currencies.map { |currency| {currency.name, currency.id} }
        options_for_select operation.currency_id, options.to_a
      end
    end
  end
end
