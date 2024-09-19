class Expenses::FormFields < BaseComponent
  needs operation : SaveExpense

  def render
    mount Shared::Field, operation.description do |html|
      html.text_input(autofocus: "true", attrs: [:required])
    end

    mount Shared::Field, operation.transaction_date, &.date_input(attrs: [:required])

    mount Shared::DummyField, label_text: "From account", input_value: operation.account.name

    mount Shared::Field, operation.amount, label_text: "Amount (#{operation.account.currency.symbol})" do |input|
      input.number_input(min: "0.01", step: "0.01")
    end

    mount Shared::Field, operation.tags do |html|
      html.multi_select_input do
        options = operation.current_user_tags.map { |tag| {tag.name, tag.id} }
        options_for_select operation.tags, options
      end
    end
  end
end
