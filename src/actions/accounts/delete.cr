class Accounts::Delete < BrowserAction
  delete "/accounts/:account_id" do
    account = AccountQuery.new.owner_id(current_user.id).find(account_id)
    DeleteAccount.delete(account) do |_operation, _deleted|
      flash.success = "Deleted the account"
      redirect Index
    end
  end
end
