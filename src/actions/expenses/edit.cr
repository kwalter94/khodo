class Expenses::Edit < BrowserAction
  param account_id : Int64

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
        .find(account_id)

    html EditPage,
      operation: SaveExpense.new(
        tx,
        account: account,
        amount: tx.from_amount,
        owner: current_user,
      ),
      transaction: tx
  end
end
