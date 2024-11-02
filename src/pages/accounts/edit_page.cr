class Accounts::EditPage < MainLayout
  needs operation : SaveAccount
  needs account : Account
  needs account_types : Enumerable(AccountType)
  needs currencies : Enumerable(Currency)

  quick_def page_title, "Edit Account with id: #{account.id}"

  def content
    link "Back to all Accounts", Accounts::Index
    h1 "Edit Account with id: #{account.id}"
    render_account_form(operation)
  end

  def render_account_form(op)
    form_for Accounts::Update.with(account.id) do
      mount Accounts::FormFields,
        operation: operation,
        account_types: account_types,
        currencies: currencies

      mount Shared::SubmitButton, "Update", data_disable_with: "Updating Accounts..."
    end
  end
end
