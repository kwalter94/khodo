class Income::Create < BrowserAction
  param account_id : Int64

  post "/income" do
    account = AccountQuery
      .new
      .owner_id(current_user.id)
      .preload_currency
      .find(account_id)

    SaveIncome.create(params, account: account, owner: current_user) do |operation, transaction|
      if transaction
        redirect Accounts::Show.with(account.id)
      else
        html Income::NewPage, operation: operation
      end
    end
  end
end
