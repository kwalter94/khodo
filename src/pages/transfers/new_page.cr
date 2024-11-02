class Transfers::NewPage < MainLayout
  needs account : Account
  needs operation : SaveTransaction

  def content
    h1 "Transfer from #{account.name}"
    render_transaction_form
  end

  def render_transaction_form
    form_for Transfers::Create.with(account_id: account.id) do
      mount Transfers::FormFields, operation: operation, account: account
      mount Shared::SubmitButton
    end
  end
end
