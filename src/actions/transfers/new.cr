class Transfers::New < BrowserAction
  param account_id : Int64 # ameba:disable Lint/UselessAssign

  get "/transfers/new" do
    account = AccountQuery
      .new
      .preload_currency
      .preload_ledger
      .owner_id(current_user.id)
      .find(account_id)

    html NewPage,
      operation: SaveTransaction.new(
        from_account_id: account.id,
        owner: current_user,
        transaction_date: Time.local
      ),
      account: account
  end
end
