class Tags::Show < BrowserAction
  param currency_id : Int64? = nil

  get "/tags/:tag_id" do
    currency = currency_id.try { |id| CurrencyQuery.new.owner_id(current_user.id).id(id).first? }
    currency ||= CurrencyQuery.find_user_default_currency(current_user.id)
    report = MonthlyTransactionsByTagReportQuery
      .new
      .user_id(current_user.id)
      .period.gte(12)
      .period.asc_order

    html ShowPage,
      tag: TagQuery.new.owner_id(current_user.id).find(tag_id),
      reporting_currency: currency,
      currencies: CurrencyQuery.new.owner_id(current_user.id).name.asc_order
  end
end
