class Accounts::Edit < BrowserAction
  get "/accounts/:account_id/edit" do
    account = AccountQuery.new.owner_id(current_user.id).find(account_id)
    html EditPage,
      operation: SaveAccount.new(account, owner: current_user),
      account: account
  end
end
