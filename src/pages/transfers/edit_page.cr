class Transfers::EditPage < MainLayout
  needs account : Account           # ameba:disable Lint/UselessAssign
  needs operation : SaveTransaction # ameba:disable Lint/UselessAssign
  needs transaction : Transaction   # ameba:disable Lint/UselessAssign

  def content
    mount Shared::BreadCrumb,
      path: [
        {"Accounts", Accounts::Index.route},
        {truncate_text(account.name), Accounts::Show.with(account.id)},
        {"Edit Transfer", Accounts::Show.with(account.id)},
      ]
    div class: "row" do
      div class: "col-12" do
        h1 "Editing Transfer ##{transaction.id}"
      end
    end

    div class: "row" do
      form_for Transfers::Update.with(transaction.id, account_id: account.id) do
        mount Transfers::FormFields, operation: operation, account: account

        mount Shared::SubmitButton, "Update", data_disable_with: "Updating Transfers..."
      end
    end
  end
end
