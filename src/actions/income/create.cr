class Income::Create < BrowserAction
  # ameba:disable Lint/UselessAssign
  param account_id : Int64

  post "/income" do
    account = AccountQuery
      .new
      .owner_id(current_user.id)
      .preload_currency
      .preload_ledger
      .find(account_id)

    SaveIncome.create(params, account: account, owner: current_user) do |op, tx|
      if tx
        redirect Accounts::Show.with(account.id)
      else
        html Income::NewPage, operation: op, account: account
      end
    end
  end
end
