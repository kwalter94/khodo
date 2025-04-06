class Transfers::FormFields < BaseComponent
  needs account : Account           # ameba:disable Lint/UselessAssign
  needs operation : SaveTransaction # ameba:disable Lint/UselessAssign

  def render
    mount Shared::Field, operation.description do |html|
      html.text_input(autofocus: "true", attrs: [:required])
    end

    mount Shared::Field, operation.transaction_date, label_text: "Date", &.date_input(attrs: [:required])

    div class: "row" do
      if operation.record.nil? || account.id == operation.from_account_id.value
        mount Shared::Field, operation.from_account_id, label_text: "From", inline: true do |html|
          html.select_input(attrs: [:disabled], value: account.id.to_s) do
            options_for_select operation.from_account_id, [{account.display_name, account.id}]
          end
        end
        mount Shared::Field, operation.from_amount, label_text: "Amount (#{account.currency.symbol})", inline: true do |input|
          input.number_input(min: "0.01", step: "0.01")
        end
      else
        mount Shared::Field, operation.from_account_id, inline: true, label_text: "To" do |html|
          html.select_input { options_for_select operation.from_account_id, account_select_options }
        end
        mount Shared::Field, operation.from_amount, label_text: "Amount" do |html|
          html.number_input(min: "0.01", step: "0.01")
        end
      end
    end

    div class: "row" do
      if account.id == operation.to_account_id.value
        mount Shared::Field, operation.to_account_id, inline: true do |html|
          html.select_input(attrs: [:disabled], label_text: "To (#{account.currency.symbol})") do
            options_for_select operation.to_account_id, [{account.display_name, account.id}]
          end
        end
        mount Shared::Field, operation.to_amount, label_text: "Amount (#{account.currency.symbol})", inline: true do |input|
          input.number_input(min: "0.01", step: "0.01")
        end
      else
        mount Shared::Field, operation.to_account_id, inline: true, label_text: "To" do |html|
          html.select_input { options_for_select operation.to_account_id, account_select_options }
        end
        mount Shared::Field, operation.to_amount, inline: true, label_text: "Amount" do |html|
          html.number_input(min: "0.01", step: "0.01")
        end
      end
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
