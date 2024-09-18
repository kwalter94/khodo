class Transfers::Create < BrowserAction
  param account_id : Int64

  post "/transfers" do
    account = AccountQuery
      .new
      .preload_currency
      .owner_id(current_user.id)
      .find(account_id)

    SaveTransaction.create(params, owner: current_user) do |operation, transaction|
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
