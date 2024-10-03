class Accounts::EditPage < MainLayout
  needs operation : SaveAccount
  needs account : Account
  quick_def page_title, "Edit Account with id: #{account.id}"

  def content
    link "Back to all Accounts", Accounts::Index
    h1 "Edit Account with id: #{account.id}"
    render_account_form(operation)
  end

  def render_account_form(op)
    form_for Accounts::Update.with(account.id) do
      # Edit fields in src/components/accounts/form_fields.cr
      mount Accounts::FormFields, op

      submit "Update", class: "btn btn-primary col col-12", data_disable_with: "Updating..."
    end
  end
end
