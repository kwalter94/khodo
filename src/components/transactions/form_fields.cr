class Transactions::FormFields < BaseComponent
  needs operation : SaveTransaction

  def render
    mount Shared::Field, operation.description do |html|
      html.text_input(autofocus: "true", attrs: [:required])
    end

    mount Shared::Field, operation.transaction_date, &.date_input(attrs: [:required])

    mount Shared::Field, operation.from_account_id do |html|
      html.select_input do
        options = operation.current_user_accounts.map do |account|
          {account.display_name, account.id}
        end
        options_for_select operation.from_account_id, options
      end
    end
    mount Shared::Field, operation.from_amount, &.number_input(min: 0)

    mount Shared::Field, operation.to_account_id do |html|
      html.select_input do
        options = operation.current_user_accounts.map do |account|
          {account.display_name, account.id}
        end
        options_for_select operation.to_account_id, options
      end
    end
    mount Shared::Field, operation.to_amount, &.number_input(min: 0)

    mount Shared::Field, operation.tags do |html|
      html.multi_select_input(attrs: [:required]) do
        options = operation.current_user_tags.map { |tag| {tag.name, tag.id} }
        options_for_select operation.tags, options
      end
    end
  end
end
