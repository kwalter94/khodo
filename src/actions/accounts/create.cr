class Accounts::Create < BrowserAction
  post "/accounts" do
    SaveAccount.create(params, owner: current_user) do |operation, account|
      if account
        flash.success = "The record has been saved"
        redirect Show.with(account.id)
      else
        flash.failure = "It looks like the form is not valid"
        html NewPage, operation: operation
      end
    end
  end
end
