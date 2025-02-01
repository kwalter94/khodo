class Transfers::Edit < BrowserAction
  param account_id : Int64

  get "/transfers/:transaction_id/edit" do
    tx =
      TransactionQuery
        .new
        .where { |where| where.from_account_id(account_id).or(&.to_account_id(account_id)) }
        .owner_id(current_user.id)
        .find(transaction_id)

    account =
      AccountQuery
        .new
        .preload_currency
        .preload_ledger
        .owner_id(current_user.id)
        .find(account_id)

    html EditPage,
      operation: SaveTransaction.new(tx, from_account_id: tx.from_account_id, to_account_id: tx.to_account_id, owner: current_user),
      transaction: tx,
      account: account
  end
end
