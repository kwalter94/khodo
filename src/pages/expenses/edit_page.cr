class Expenses::EditPage < MainLayout
  needs operation : SaveExpense
  needs transaction : Transaction

  def content
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
