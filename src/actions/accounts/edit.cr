class Accounts::Edit < BrowserAction
  get "/accounts/:account_id/edit" do
    account = AccountQuery.new.owner_id(current_user.id).find(account_id)

    html EditPage,
      operation: SaveAccount.new(account, owner: current_user),
      account: account,
      account_types: AccountTypeQuery.user_managed_account_types.name.asc_order,
      currencies: CurrencyQuery.find_user_currencies(current_user.id).name.asc_order
  end
end
