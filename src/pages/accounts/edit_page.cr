class Accounts::EditPage < MainLayout
  needs operation : SaveAccount                 # ameba:disable Lint/UselessAssign
  needs account : Account                       # ameba:disable Lint/UselessAssign
  needs account_types : Enumerable(AccountType) # ameba:disable Lint/UselessAssign
  needs currencies : Enumerable(Currency)       # ameba:disable Lint/UselessAssign

  quick_def page_title, "Edit Account ##{account.id}"

  def content
    mount Shared::BreadCrumb,
      path: [
        {"Accounts", Accounts::Index.route},
        {truncate_text(account.name), Accounts::Show.with(account.id)},
        {"Edit", Accounts::Edit.with(account.id)},
      ]

    h1 "Editing \"#{account.name}\""
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
