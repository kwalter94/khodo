class Income::New < BrowserAction
  param account_id : Int64 # ameba:disable Lint/UselessAssign

  get "/income/new/" do
    account = AccountQuery
      .new
      .preload_currency
      .preload_ledger
      .owner_id(current_user.id)
      .find(account_id)

    html NewPage,
      account: account,
      operation: SaveIncome.new(
        account: account,
        owner: current_user,
        transaction_date: Time.local,
      )
  end
end
