class Accounts::FormFields < BaseComponent
  needs operation : SaveAccount

  def render
    div class: "mb-3" do
      mount Shared::Field, operation.name, &.text_input(autofocus: "true")
    end

    div class: "mb-3" do
      mount Shared::Field, operation.type_id do |html|
        html.select_input do
          options = operation.account_types.map { |type| {type.name, type.id} }
          options_for_select operation.type_id, options
        end
      end
    end

    div class: "mb-3" do
      mount Shared::Field, operation.currency_id do |html|
        html.select_input do
          options = operation.currencies.map { |currency| {currency.name, currency.id} }
          options_for_select operation.currency_id, options
        end
      end
    end
  end
end
