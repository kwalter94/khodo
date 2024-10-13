class Accounts::Index < BrowserAction
  param currency_id : Int64? = nil

  get "/accounts" do
    currency = currency_id.try { |id| CurrencyQuery.new.owner_id(current_user.id).id(id).first? }
    currency ||= CurrencyQuery.find_user_default_currency(current_user.id)

    report = CumulativeAccountBalanceReportQuery
      .new
      .owner_id(current_user.id)
      .currency_id(currency.id)
      .period(1)
      .account_type_name.asc_order
      .account_name.asc_order
      .currency_name.asc_order

    currencies = CurrencyQuery.new.owner_id(current_user.id).name.asc_order

    html IndexPage,
      accounts: report,
      reporting_currency: currency,
      currencies: currencies
  end
end
