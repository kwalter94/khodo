class Home::Index < BrowserAction
  Log = ::Log.for(self)

  param currency_id : Int64? = nil # ameba:disable Lint/UselessAssign

  get "/" do
    currency = find_reporting_currency
    flash_missing_currencies(currency)

    report = account_balance_report(currency)
    total_assets, new_assets = total_balance(report, "Asset")
    total_liabilities, new_liabilities = total_balance(report, "Liability")

    html Home::IndexPage,
      reporting_currency: currency,
      currencies: user_currencies,
      total_assets: total_assets,
      new_assets: new_assets,
      total_liabilities: total_liabilities,
      new_liabilities: new_liabilities
  rescue error : UserProperties::ConfigurationError
    flash.info = "You need to set a default currency first!"
    Log.warn(exception: error) { "Missing user properties" }
    redirect to: UserProperties::Edit
  end

  private def find_reporting_currency : Currency
    currency = currency_id.try { |id| CurrencyQuery.new.owner_id(current_user.id).find(id) }
    currency || CurrencyQuery.find_user_default_currency(current_user.id)
  end

  private def flash_missing_currencies(target_currency : Currency)
    exchange_rate_matrix = ExchangeRateMatrixQuery
      .new
      .owner_id(current_user.id)
      .to_currency_id(target_currency.id)
      .rate.is_nil

    return if exchange_rate_matrix.size == 0

    conversions = exchange_rate_matrix
      .map { |matrix| "#{matrix.from_currency_name} (#{matrix.from_currency_symbol}) => #{matrix.to_currency_name} (#{matrix.to_currency_symbol})" }
      .join(", ")

    flash.set("warning", "You may be viewing innacurate reports due to missing currency conversions: #{conversions}")
  end

  private def account_balance_report(currency : Currency) : CumulativeAccountBalanceReportQuery
    CumulativeAccountBalanceReportQuery
      .new
      .owner_id(current_user.id)
      .currency_id(currency.id)
      .period(1)
  end

  private def total_balance(report : CumulativeAccountBalanceReportQuery, account_type_name : String) : Tuple(Float64, Float64)
    report
      .select { |account| account.account_type_name == account_type_name }
      .reduce({0.0.to_f64, 0.0.to_f64}) { |accum, account| {account.balance + accum[0], account.net_receipts + accum[1]} }
  end

  private def user_currencies : Enumerable(Currency)
    CurrencyQuery.new.owner_id(current_user.id)
  end
end
