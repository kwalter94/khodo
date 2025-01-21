class Transfers::NewPage < MainLayout
  needs account : Account           # ameba:disable Lint/UselessAssign
  needs operation : SaveTransaction # ameba:disable Lint/UselessAssign

  def content
    mount Shared::BreadCrumb,
      path: [
        {"Accounts", Accounts::Index.route},
        {truncate_text(account.name), Accounts::Show.with(account.id)},
        {"New Transfer", Transfers::New.route(account_id: account.id)},
      ]

    div class: "row" do
      h1 "Transfer from #{account.name}"
    end

    div class: "row" do
      render_transaction_form
    end
  end

  def render_transaction_form
    form_for Transfers::Create.with(account_id: account.id) do
      mount Transfers::FormFields, operation: operation, account: account
      mount Shared::SubmitButton
    end
  end
end
