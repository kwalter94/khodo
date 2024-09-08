class Transactions::Edit < BrowserAction
  get "/transactions/:transaction_id/edit" do
    transaction = TransactionQuery.find(transaction_id)
    html EditPage,
      operation: SaveTransaction.new(transaction, owner: current_user),
      transaction: transaction
  end
end
