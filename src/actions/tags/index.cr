class Tags::Index < BrowserAction
  param currency_id : Int64? = nil

  get "/tags" do
    currency = currency_id.try { |id| CurrencyQuery.new.owner_id(current_user.id).id(id).first? }
    currency ||= CurrencyQuery.find_user_default_currency(current_user.id)

    report = MonthlyTransactionsByTagReportQuery
      .new
      .user_id(current_user.id)
      .period(1)
      .currency_id(currency.id)
      .tag_name.asc_order

    html IndexPage,
      report: report,
      reporting_currency: currency,
      currencies: CurrencyQuery.new.owner_id(current_user.id).name.asc_order
  rescue error : UserProperties::ConfigurationError
    Log.warn(exception: error) { "Missing user properties!" }
    flash.info = error.to_s
    redirect to: UserProperties::Edit
  end
end
