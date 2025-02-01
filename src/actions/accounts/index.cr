class Accounts::Index < BrowserAction
  param ledger_id : Int64 = nil    # ameba:disable Lint/UselessAssign
  param currency_id : Int64? = nil # ameba:disable Lint/UselessAssign

  get "/accounts" do
    currency = currency_id.try { |id| CurrencyQuery.new.owner_id(current_user.id).id(id).first? }
    currency ||= CurrencyQuery.find_user_default_currency(current_user.id)
    report = CumulativeAccountBalanceReportQuery
      .new
      .owner_id(current_user.id)
      .currency_id(currency.id)
      .ledger_id(ledger_id || current_user_general_ledger.id)
      .period(1)
      .account_type_name.asc_order
      .account_name.asc_order
      .currency_name.asc_order
    currencies = CurrencyQuery.new.owner_id(current_user.id).name.asc_order
    ledger = LedgerQuery.new.find(ledger_id)

    html IndexPage,
      accounts: report,
      reporting_currency: currency,
      currencies: currencies,
      ledger: ledger
  rescue error : UserProperties::ConfigurationError
    Log.warn(exception: error) { "Missing user properties!" }
    flash.info = error.to_s
    redirect to: UserProperties::Edit
  end

  private def current_user_general_ledger : Ledger
    raise "Not implemented!"
  end
end
