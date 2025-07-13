class Tags::Index < BrowserAction
  get "/tags" do
    report = Reports::MonthlyTransactionsByTagQuery
      .new
      .user_id(current_user.id)
      .period(1)
      .currency_id(reporting_currency.id)

    html IndexPage,
      report: report,
      currencies: CurrencyQuery.new.owner_id(current_user.id).name.asc_order
  end
end
