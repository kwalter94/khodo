class Transactions::Edit < BrowserAction
  get "/transactions/:transaction_id/edit" do
    transaction = TransactionQuery.find(transaction_id)
    operation = SaveTransaction.new(transaction, owner: current_user)

    html EditPage,
      operation: operation,
      transaction: transaction
  end
end
