class Transfers::NewPage < MainLayout
  needs operation : SaveTransfer

  def content
    h1 "Transfer from #{operation.account.name}"
    render_transaction_form(operation)
  end

  def render_transaction_form(op)
    form_for Transfers::Create.with(account_id: operation.account.id) do
      mount Transfers::FormFields, op

      submit "Save", class: "btn btn-primary", data_disable_with: "Saving..."
    end
  end
end
