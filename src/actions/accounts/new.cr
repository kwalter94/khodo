class Accounts::New < BrowserAction
  get "/accounts/new" do
    html NewPage,
      operation: SaveAccount.new(owner: current_user),
      account_types: AccountTypeQuery.user_managed_account_types.name.asc_order,
      currencies: CurrencyQuery.find_user_currencies(current_user.id).name.asc_order
  end
end
