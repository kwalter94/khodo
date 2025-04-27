class Accounts::Show < BrowserAction
  param search_description : String? # ameba:disable Lint/UselessAssign

  get "/accounts/:account_id" do
    balance = Reports::AccountBalanceQuery
      .new
      .owner_id(current_user.id)
      .find(account_id.to_i64)
    currency = CurrencyQuery.new.find(balance.currency_id)

    transactions = find_transactions(balance)
    pages, transactions = paginate(transactions, per_page: 10)

    html ShowPage,
      account_balance: balance,
      currency: currency,
      pages: pages,
      search_description: search_description,
      transactions: transactions
  end

  def find_transactions(balance : Reports::AccountBalance) : TransactionQuery
    transactions = TransactionQuery
      .new
      .preload_from_account { |account_query| account_query.preload_type.preload_currency }
      .preload_to_account { |account_query| account_query.preload_type.preload_currency }
      .preload_tags
      .owner_id(current_user.id)
      .where { |where| where.to_account_id(balance.account_id).or(&.from_account_id(balance.account_id)) }
      .transaction_date.desc_order

    return transactions if search_description.blank?

    transactions.description.ilike("%#{search_description}%")
  end
end
