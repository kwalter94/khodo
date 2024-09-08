class Transactions::Show < BrowserAction
  get "/transactions/:transaction_id" do
    query = TransactionQuery.new.owner_id(current_user.id).find(transaction_id)
    html ShowPage, transaction: query
  end
end
