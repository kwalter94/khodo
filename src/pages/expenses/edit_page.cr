class Expenses::EditPage < MainLayout
  needs operation : SaveExpense   # ameba:disable Lint/UselessAssign
  needs transaction : Transaction # ameba:disable Lint/UselessAssign

  def content
    mount Shared::BreadCrumb,
      path: [
        {"Accounts", Accounts::Index.route},
        {truncate_text(operation.account.name), Accounts::Show.with(operation.account.id)},
        {"Edit Expense", Accounts::Show.with(operation.account.id)},
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
