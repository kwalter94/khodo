class Income::Edit < BrowserAction
  param account_id : Int64 # ameba:disable Lint/UselessAssign

  get "/income/:transaction_id/edit" do
    tx = TransactionQuery
      .new
      .owner_id(current_user.id)
      .to_account_id(account_id)
      .find(transaction_id)
    account = AccountQuery
      .new
      .preload_currency
      .preload_ledger
      .owner_id(current_user.id)
      .find(account_id)

    html EditPage,
      operation: SaveIncome.new(
        tx,
        account: account,
        amount: tx.to_amount,
        owner: current_user,
      ),
      transaction: tx,
      account: account
  end
end
