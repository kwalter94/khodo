class Transfers::Update < BrowserAction
  param account_id : Int64 # ameba:disable Lint/UselessAssign

  put "/transfers/:transaction_id" do
    tx = TransactionQuery
      .new
      .where { |where| where.from_account_id(account_id).or(&.to_account_id(account_id)) }
      .owner_id(current_user.id)
      .find(transaction_id)

    account = AccountQuery
      .new
      .owner_id(current_user.id)
      .preload_currency
      .preload_ledger
      .find(account_id)

    SaveTransaction.update(tx, params, owner: current_user) do |operation, _|
      if operation.updated?
        redirect Accounts::Show.with(account_id)
      else
        html EditPage, transaction: tx, operation: operation, account: account
      end
    end
  end
end
