class Accounts::NewPage < MainLayout
  needs operation : SaveAccount
  needs account_types : Enumerable(AccountType)
  needs currencies : Enumerable(Currency)

  quick_def page_title, "New Account"

  def content
    h1 "New Account", class: "col col-10"
    render_account_form(operation)
  end

  def render_account_form(operation)
    div class: "row" do
      form_for Accounts::Create, class: "col col-10" do
        # Edit fields in src/components/accounts/form_fields.cr
        mount Accounts::FormFields,
          operation: operation,
          account_types: account_types,
          currencies: currencies

        mount Shared::SubmitButton
      end
    end
  end
end
