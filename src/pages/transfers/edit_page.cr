class Transfers::EditPage < MainLayout
  needs account : Account
  needs operation : SaveTransaction
  needs transaction : Transaction

  def content
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
