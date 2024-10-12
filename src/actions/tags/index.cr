class Tags::Index < BrowserAction
  param currency_id : Int64? = nil

  get "/tags" do
    currency = currency_id.try do |id|
      CurrencyQuery.new.owner_id(current_user.id).id(id).first?
    end

    currency ||= CurrencyQuery.find_user_default_currency(current_user.id)

    report = MonthlyTransactionsByTagReportQuery
      .new
      .user_id(current_user.id)
      .period(1)
      .currency_id(currency.id)
      .tag_name.asc_order

    html IndexPage, report: report, currency: currency
  end
end
