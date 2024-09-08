class Accounts::NewPage < MainLayout
  needs operation : SaveAccount
  quick_def page_title, "New Account"

  def content
    h1 "New Account"
    render_account_form(operation)
  end

  def render_account_form(op)
    form_for Accounts::Create do
      # Edit fields in src/components/accounts/form_fields.cr
      mount Accounts::FormFields, op

      submit "Save", data_disable_with: "Saving..."
    end
  end
end
