class Expenses::NewPage < MainLayout
  needs operation : SaveExpense # ameba:disable Lint/UselessAssign

  def content
    mount Shared::BreadCrumb,
      path: [
        {"Accounts", Accounts::Index.route},
        {truncate_text(operation.account.name), Accounts::Show.with(operation.account.id)},
        {"New Expense", Expenses::New.route(account_id: operation.account.id)},
      ]
    div class: "row" { h1 "Expense from #{operation.account.name}" }
    div class: "row" { render_form }
  end

  def render_form
    div class: "col-12" do
      form_for Expenses::Create.with(account_id: operation.account.id) do
        mount Expenses::FormFields, operation

        mount Shared::SubmitButton
      end
    end
  end
end
