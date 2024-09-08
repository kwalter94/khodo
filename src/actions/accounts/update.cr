class Accounts::Update < BrowserAction
  put "/accounts/:account_id" do
    account = AccountQuery.new.owner_id(current_user.id).find(account_id)
    SaveAccount.update(account, params, owner: current_user) do |operation, updated_account|
      if operation.saved?
        flash.success = "The record has been updated"
        redirect Show.with(updated_account.id)
      else
        flash.failure = "It looks like the form is not valid"
        html EditPage, operation: operation, account: updated_account
      end
    end
  end
end
