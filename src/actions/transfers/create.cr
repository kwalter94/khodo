class Transfers::Create < BrowserAction
  param account_id : Int64 # ameba:disable Lint/UselessAssign

  post "/transfers" do
    account = AccountQuery
      .new
      .preload_currency
      .preload_ledger
      .owner_id(current_user.id)
      .find(account_id)

    SaveTransaction.create(params, from_account_id: account.id, owner: current_user) do |operation, transaction|
      if transaction
        flash.success = "Transfer successful"
        redirect Accounts::Show.with(account_id)
      else
        flash.failure = "Error creating transfer"
        html NewPage, operation: operation, account: account
      end
    end
  end
end
