class Accounts::Index < BrowserAction
  param ledger_id : Int64 = nil # ameba:disable Lint/UselessAssign

  get "/accounts" do
    report = Reports::AccountBalanceQuery
      .new
      .owner_id(current_user.id)
      .ledger_id(ledger_id || current_user_general_ledger.id)
      .reject { |row| ["Expense", "Income"].includes?(row.account_type_name) }

    currencies = CurrencyQuery
      .new
      .owner_id(current_user.id)
      .name.asc_order

    exchange_rates = ExchangeRateMatrixQuery
      .new
      .owner_id(current_user.id)
      .to_currency_id(reporting_currency.id)
      .each_with_object({} of Int64 => Float64?) { |exchange_rate, hash| hash[exchange_rate.from_currency_id] = exchange_rate.rate }

    ledger = LedgerQuery.new.find(ledger_id)

    html IndexPage,
      report: report,
      currencies: currencies,
      ledger: ledger,
      exchange_rates: exchange_rates
  end

  private def current_user_general_ledger : Ledger
    raise "Not implemented!"
  end
end
