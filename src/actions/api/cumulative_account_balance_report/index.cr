class Api::CumulativeAccountBalanceReport::Index < BrowserAction
  param currency_id : Int64? = nil

  get "/api/cumulative_assets_report" do
    currency = currency_id.try { |id| CurrencyQuery.new.owner_id(current_user.id).id(id).first }
    currency ||= CurrencyQuery.find_user_default_currency(current_user.id)

    report = CumulativeAccountBalanceReportQuery
      .new
      .owner_id(current_user.id)
      .currency_id(currency.id)
      .month.asc_order

    json CumulativeAccountBalanceReportSerializer.for_collection(report)
  end
end
