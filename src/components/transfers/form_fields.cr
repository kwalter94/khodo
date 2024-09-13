class Transfers::FormFields < BaseComponent
  needs operation : SaveTransfer

  def render
    mount Shared::Field, operation.description do |html|
      html.text_input(autofocus: "true", attrs: [:required])
    end

    mount Shared::Field, operation.transaction_date, &.date_input(attrs: [:required])

    mount Shared::Field, operation.to_account_id do |html|
      html.select_input do
        options = operation
          .current_user_accounts
          .map { |account| {account.display_name, account.id} }
          .select { |_, account_id| account_id != operation.account.id }

        options_for_select operation.to_account_id, options
      end
    end

    mount Shared::Field, operation.from_amount, label_text: "From amount (#{operation.account.currency.symbol})", &.number_input(min: 0)

    mount Shared::Field, operation.to_amount, &.number_input(min: 0)

    mount Shared::Field, operation.tags do |html|
      html.multi_select_input(attrs: [:required]) do
        options = operation.current_user_tags.map { |tag| {tag.name, tag.id} }
        options_for_select operation.tags, options
      end
    end
  end
end
