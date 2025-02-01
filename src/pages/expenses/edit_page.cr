class Expenses::EditPage < MainLayout
  needs account : Account         # ameba:disable Lint/UselessAssign
  needs operation : SaveExpense   # ameba:disable Lint/UselessAssign
  needs transaction : Transaction # ameba:disable Lint/UselessAssign

  def content
    mount Shared::BreadCrumb,
      path: [
        {"#{account.ledger.try(&.name)} Accounts", Accounts::Index.route(ledger_id: account.ledger_id)},
        {truncate_text(account.name), Accounts::Show.with(account.id)},
        {"Edit Expense", Expenses::New.route(account_id: account.id)},
      ]
    h1 "Editing expense ##{transaction.id}"
    render_transaction_form(operation)
  end

  def render_transaction_form(op)
    form_for Expenses::Update.with(transaction.id, account_id: operation.account.id) do
      mount Expenses::FormFields, op

      mount Shared::SubmitButton, "Update", data_disable_with: "Updating Expense"
    end
  end
end
