class Transactions::Index < BrowserAction
  get "/transactions" do
    html IndexPage, transactions: TransactionQuery.new.owner_id(current_user.id)
  end
end
