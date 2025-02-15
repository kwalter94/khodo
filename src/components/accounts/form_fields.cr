class Accounts::FormFields < BaseComponent
  needs operation : SaveAccount                 # ameba:disable Lint/UselessAssign
  needs account_types : Enumerable(AccountType) # ameba:disable Lint/UselessAssign
  needs currencies : Enumerable(Currency)       # ameba:disable Lint/UselessAssign
  needs ledgers : Enumerable(Ledger)

  def render
    div class: "mb-3" do
      mount Shared::Field, operation.name, &.text_input(autofocus: "true")
    end

    div class: "mb-3" do
      mount Shared::Field, operation.type_id do |html|
        html.select_input do
          options = account_types.map { |type| {type.name, type.id} }
          options_for_select operation.type_id, options
        end
      end
    end

    div class: "mb-3" do
      mount Shared::Field, operation.ledger_id do |html|
        html.select_input(attrs: [:required]) do
          options = ledgers.map { |ledger| {ledger.name, ledger.id} }
          options_for_select operation.ledger_id, options
        end
      end
    end

    div class: "mb-3" do
      mount Shared::Field, operation.currency_id do |html|
        html.select_input do
          options = currencies.map { |currency| {currency.name, currency.id} }
          options_for_select operation.currency_id, options
        end
      end
    end
  end
end
