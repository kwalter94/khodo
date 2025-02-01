class Income::NewPage < MainLayout
  needs account : Account      # ameba:disable Lint/UselessAssign
  needs operation : SaveIncome # ameba:disable Lint/UselessAssign

  def content
    mount Shared::BreadCrumb,
      path: [
        {"#{account.ledger.try(&.name)} Accounts", Accounts::Index.route(ledger_id: account.ledger_id)},
        {truncate_text(operation.account.name), Accounts::Show.with(operation.account.id)},
        {"New Income", Income::New.route(account_id: operation.account.id)},
      ]
    div class: "row" { h1 "Income to #{operation.account.name}" }
    div class: "row" { render_form }
  end

  def render_form
    div class: "col col-12" do
      form_for Income::Create.with(account_id: operation.account.id) do
        mount Income::FormFields, operation

        mount Shared::SubmitButton
      end
    end
  end
end
