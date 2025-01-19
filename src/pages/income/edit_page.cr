class Income::EditPage < MainLayout
  needs operation : SaveIncome    # ameba:disable Lint/UselessAssign
  needs transaction : Transaction # ameba:disable Lint/UselessAssign

  def content
    mount Shared::BreadCrumb,
      path: [
        {"Accounts", Accounts::Index.route},
        {truncate_text(operation.account.name), Accounts::Show.with(operation.account.id)},
        {"Edit Income", Accounts::Show.with(operation.account.id)},
      ]
    h1 "Editing income receipt ##{transaction.id}"
    render_transaction_form(operation)
  end

  def render_transaction_form(op)
    form_for Income::Update.with(transaction.id, account_id: operation.account.id) do
      mount Income::FormFields, op
      mount Shared::SubmitButton, "Update", data_disable_with: "Saving Income"
    end
  end
end
