class Tags::Show < BrowserAction
  include Lucky::Paginator::BackendHelpers

  param search_tx : String? = nil # ameba:disable Lint/UselessAssign

  @tag : Tag?

  get "/tags/:tag_id" do
    pages, transactions = paginate(transactions_by_tag(tag), per_page: 10)

    html ShowPage,
      tag: tag,
      transactions: transactions,
      pages: pages,
      currencies: currencies,
      exchange_rates: exchange_rates,
      search_tx: search_tx || ""
  end

  def transactions_by_tag(tag : Tag) : TransactionQuery
    transactions = TransactionQuery
      .new
      .where_tags(TagQuery.new.id(tag.id))
      .owner_id(current_user.id)
      .preload_from_account(AccountQuery.new.preload_currency)
      .preload_to_account(AccountQuery.new.preload_currency)
      .transaction_date.desc_order

    return transactions if search_tx.blank?

    transactions.description.ilike("%#{search_tx}%")
  end

  def currency : Currency
    currency = currency_id.try do |id|
      CurrencyQuery.new.owner_id(current_user.id).id(id).first?
    end

    currency || CurrencyQuery.find_user_default_currency(current_user.id)
  end

  def currencies : Enumerable(Currency)
    CurrencyQuery.new.owner_id(current_user.id).name.asc_order
  end

  def tag : Tag
    @tag ||= TagQuery.new.owner_id(current_user.id).find(tag_id)
  end

  def exchange_rates : ExchangeRateMatrixQuery::Table
    ExchangeRateMatrixQuery.new.owner_id(current_user.id).as_table
  end
end
