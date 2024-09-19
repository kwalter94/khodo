class Transfers::FormFields < BaseComponent
  needs account : Account
  needs operation : SaveTransaction

  def render
    mount Shared::Field, operation.description do |html|
      html.text_input(autofocus: "true", attrs: [:required])
    end

    mount Shared::Field, operation.transaction_date, &.date_input(attrs: [:required])

    if operation.record.nil? || account.id == operation.from_account_id.value
      mount Shared::Field, operation.from_account_id, label_text: "From account" do |html|
        html.select_input(attrs: [:disabled], value: account.id.to_s) do
          options_for_select operation.from_account_id, [{account.display_name, account.id}]
        end
      end
      mount Shared::Field, operation.from_amount, label_text: "From amount (#{account.currency.symbol})" do |input|
        input.number_input(min: "0.01", step: "0.01")
      end
    else
      mount Shared::Field, operation.from_account_id do |html|
        html.select_input { options_for_select operation.from_account_id, account_select_options }
      end
      mount Shared::Field, operation.from_amount, &.number_input(min: 0)
    end

    if account.id == operation.to_account_id.value
      mount Shared::Field, operation.to_account_id do |html|
        html.select_input(attrs: [:disabled], label_text: "To account (#{account.currency.symbol})") do
          options_for_select operation.to_account_id, [{account.display_name, account.id}]
        end
      end
      mount Shared::Field, operation.to_amount, label_text: "To account (#{account.currency.symbol})" do |input|
        input.number_input(min: "0.01", step: "0.01")
      end
    else
      mount Shared::Field, operation.to_account_id do |html|
        html.select_input { options_for_select operation.to_account_id, account_select_options }
      end
      mount Shared::Field, operation.to_amount, &.number_input(min: "0.01", step: "0.01")
    end

    mount Shared::Field, operation.tags do |html|
      html.multi_select_input(attrs: [:required]) do
        options = operation.current_user_tags.map { |tag| {tag.name, tag.id} }
        options_for_select operation.tags, options
      end
    end
  end

  @account_select_options : Array(Tuple(String, Int64))?

  def account_select_options : Array(Tuple(String, Int64))
    @account_select_options ||= operation
      .current_user_accounts
      .map { |account| {account.display_name, account.id} }
      .select { |_, account_id| account_id != account.id }
  end
end
