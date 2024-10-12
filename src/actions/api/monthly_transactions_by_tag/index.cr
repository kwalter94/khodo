class Api::MonthlyTransactionsByTag < BrowserAction
  param tag_id : Int64? = nil
  param currency_id : Int64? = nil
  param periods : Int64 = 12.to_i64

  get "/api/monthly_transactions_by_tag_report" do
    currency = currency_id.try { |id| CurrencyQuery.new.owner_id(current_user.id).id(id).first? }
    currency ||= CurrencyQuery.find_user_default_currency(current_user.id)
    report = MonthlyTransactionsByTagReportQuery
      .new
      .user_id(current_user.id)
      .currency_id(currency.id)
      .period.lte(periods)
      .month.asc_order

    filter = tag_id # Shush compiler from complaining about potential nil from tag_id
    report = report.tag_id(filter) if filter

    json MonthlyTransactionsByTagReportSerializer.for_collection(report)
  end
end
