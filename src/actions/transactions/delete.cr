class Transactions::Delete < BrowserAction
  delete "/transactions/:transaction_id" do
    transaction = TransactionQuery.new.owner_id(current_user.id).find(transaction_id)
    DeleteTransaction.delete(transaction) do |_operation, _deleted|
      flash.success = "Deleted the transaction"
      redirect Index
    end
  end
end
