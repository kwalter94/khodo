class Accounts::Delete < BrowserAction
  delete "/accounts/:account_id" do
    account = AccountQuery.new.owner_id(current_user.id).find(account_id)
    DeleteAccount.delete(account) do |_operation, _deleted|
      flash.success = "Deleted account: #{account.name}"
      redirect Index.path(ledger_id: account.ledger_id)
    end
  end
end
