class Transactions::Delete < BrowserAction
  param account_id : Int64? = nil

  delete "/transactions/:transaction_id" do
    transaction = TransactionQuery.new.owner_id(current_user.id).find(transaction_id)
    DeleteTransaction.delete(transaction) do |_operation, _deleted|
      flash.success = "Deleted the transaction"

      id = account_id
      if id
        redirect Accounts::Show.with(id)
      else
        redirect Index
      end
    end
  end
end
