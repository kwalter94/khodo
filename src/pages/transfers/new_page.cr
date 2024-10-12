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

      div class: "d-grid gap-2" do
        submit "Save", class: "btn btn-primary", data_disable_with: "Saving..."
      end
    end
  end
end
