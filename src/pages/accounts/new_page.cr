class Accounts::NewPage < MainLayout
  needs operation : SaveAccount                 # ameba:disable Lint/UselessAssign
  needs account_types : Enumerable(AccountType) # ameba:disable Lint/UselessAssign
  needs currencies : Enumerable(Currency)       # ameba:disable Lint/UselessAssign

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
          currencies: currencies,
          ledgers: ledgers

        mount Shared::SubmitButton
      end
    end
  end
end
