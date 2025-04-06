class Tags::Show < BrowserAction
  include Lucky::Paginator::BackendHelpers

  param currency_id : Int64? = nil # ameba:disable Lint/UselessAssign

  get "/tags/:tag_id" do
    currency = currency_id.try { |id| CurrencyQuery.new.owner_id(current_user.id).id(id).first? }
    currency ||= CurrencyQuery.find_user_default_currency(current_user.id)
    tag = TagQuery.new.owner_id(current_user.id).find(tag_id)
    exchange_rates = ExchangeRateMatrixQuery
      .new
      .owner_id(current_user.id)
      .as_table
    transactions = TransactionQuery
      .new
      .where_tags(TagQuery.new.id(tag.id))
      .owner_id(current_user.id)
      .preload_from_account(AccountQuery.new.preload_currency)
      .preload_to_account(AccountQuery.new.preload_currency)
      .transaction_date.desc_order
    pages, transactions = paginate(transactions, per_page: 10)

    html ShowPage,
      tag: tag,
      transactions: transactions,
      pages: pages,
      reporting_currency: currency,
      currencies: CurrencyQuery.new.owner_id(current_user.id).name.asc_order,
      exchange_rates: exchange_rates
  end
end
