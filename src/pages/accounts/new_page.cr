class Accounts::NewPage < MainLayout
  needs operation : SaveAccount
  quick_def page_title, "New Account"

  def content
    h1 "New Account", class: "col col-10"
    render_account_form(operation)
  end

  def render_account_form(op)
    div class: "row" do
      form_for Accounts::Create, class: "col col-10" do
        # Edit fields in src/components/accounts/form_fields.cr
        mount Accounts::FormFields, op

        submit "Save", class: "btn btn-primary", data_disable_with: "Saving..."
      end
    end
  end
end
