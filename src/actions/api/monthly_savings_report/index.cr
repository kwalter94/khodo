class Api::MonthlySavingsReport::Index < BrowserAction
  param currency_id : Int64?

  get "/api/monthly_savings_report" do
    currency = currency_id.try do |id|
      CurrencyQuery.new.owner_id(current_user.id).id(id).first
    end

    currency ||= CurrencyQuery.find_user_default_currency(current_user.id)
    query = MonthlySavingsReportQuery.new
      .user_id(current_user.id)
      .currency_id(currency.id)
      .month.asc_order
      .savings.desc_order

    json MonthlySavingsReportSerializer.for_collection(query)
  end
end
