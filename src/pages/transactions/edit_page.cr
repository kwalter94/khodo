class Transactions::EditPage < MainLayout
  needs operation : SaveTransaction
  needs transaction : Transaction
  quick_def page_title, "Edit Transaction with id: #{transaction.id}"

  def content
    link "Back to all Transactions", Transactions::Index
    h1 "Edit Transaction with id: #{transaction.id}"
    render_transaction_form(operation)
  end

  def render_transaction_form(op)
    form_for Transactions::Update.with(transaction.id) do
      # Edit fields in src/components/transactions/form_fields.cr
      mount Transactions::FormFields, op

      submit "Update", data_disable_with: "Updating..."
    end
  end
end
