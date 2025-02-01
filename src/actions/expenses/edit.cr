class Expenses::Edit < BrowserAction
  param account_id : Int64 # ameba:disable Lint/UselessAssign

  get "/expenses/:transaction_id/edit" do
    tx =
      TransactionQuery
        .new
        .owner_id(current_user.id)
        .from_account_id(account_id)
        .find(transaction_id)

    account =
      AccountQuery
        .new
        .preload_currency
        .owner_id(current_user.id)
        .preload_ledger
        .find(account_id)

    html EditPage,
      account: account,
      operation: SaveExpense.new(
        tx,
        account: account,
        amount: tx.from_amount,
        owner: current_user,
      ),
      transaction: tx
  end
end
