class Expenses::NewPage < MainLayout
  needs account : Account       # ameba:disable Lint/UselessAssign
  needs operation : SaveExpense # ameba:disable Lint/UselessAssign

  def content
    mount Shared::BreadCrumb,
      path: [
        {"#{account.ledger.try(&.name)} Accounts", Accounts::Index.route(ledger_id: account.ledger_id)},
        {truncate_text(account.name), Accounts::Show.with(account.id)},
        {"New Expense", Expenses::New.route(account_id: account.id)},
      ]
    div class: "row" { h1 "Expense from #{account.name}" }
    div class: "row" { render_form }
  end

  def render_form
    div class: "col-12" do
      form_for Expenses::Create.with(account_id: account.id) do
        mount Expenses::FormFields, operation

        mount Shared::SubmitButton
      end
    end
  end
end
