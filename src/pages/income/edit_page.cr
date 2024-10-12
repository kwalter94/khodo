class Income::EditPage < MainLayout
  needs operation : SaveIncome
  needs transaction : Transaction

  def content
    h1 "Editing income receipt ##{transaction.id}"
    render_transaction_form(operation)
  end

  def render_transaction_form(op)
    form_for Income::Update.with(transaction.id, account_id: operation.account.id) do
      mount Income::FormFields, op

      submit "Update", class: "btn btn-primary col-12", data_disable_with: "Updating..."
    end
  end
end
