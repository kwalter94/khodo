class Income::Update < BrowserAction
  param account_id : Int64

  put "/income/:transaction_id" do
    tx = TransactionQuery
      .new
      .owner_id(current_user.id)
      .to_account_id(account_id)
      .find(transaction_id)

    account = AccountQuery
      .new
      .preload_currency
      .owner_id(current_user.id)
      .find(account_id)

    SaveIncome.update(tx, params, account: account, owner: current_user) do |operation, updated_tx|
      if operation.saved?
        flash.success = "Income transaction ##{updated_tx.id} saved"
        redirect Accounts::Show.with(account_id)
      else
        flash.failure = "Error updating income transaction ##{updated_tx.id}"
        html EditPage, operation: operation, transaction: updated_tx
      end
    end
  end
end
