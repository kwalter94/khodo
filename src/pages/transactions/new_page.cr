class Transactions::NewPage < MainLayout
  needs operation : SaveTransaction
  quick_def page_title, "New Transaction"

  def content
    h1 "New Transaction"
    render_transaction_form(operation)
  end

  def render_transaction_form(op)
    form_for Transactions::Create do
      # Edit fields in src/components/transactions/form_fields.cr
      mount Transactions::FormFields, op

      mount Shared::SubmitButton, data_disable_with: "Saving Tx"
    end
  end
end
