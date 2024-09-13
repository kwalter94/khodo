class Expenses::Create < BrowserAction
  param account_id : Int64

  post "/expenses" do
    account = AccountQuery
      .new
      .owner_id(current_user.id)
      .preload_currency
      .find(account_id)

    SaveExpense.create(params, account: account, owner: current_user) do |operation, transaction|
      if transaction
        redirect Accounts::Show.with(account.id)
      else
        html Expenses::NewPage, operation: operation
      end
    end
  end
end
