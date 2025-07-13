class Home::Index < BrowserAction
  Log = ::Log.for(self)

  get "/" do
    validate_reporting_currency_exchange_matrix

    report = Reports::CumulativeAccountBalanceQuery
      .new
      .owner_id(current_user.id)
      .currency_id(reporting_currency.id)
      .period(1)

    user_currencies = CurrencyQuery.new.owner_id(current_user.id).name.asc_order

    assets = total_balance(report, "Asset")
    liabilities = total_balance(report, "Liability")

    html Home::IndexPage,
      currencies: user_currencies,
      net_worth: Home::IndexPage::NetWorth.new(
        total_assets: assets[:total],
        new_assets: assets[:new_receipts],
        total_liabilities: liabilities[:total],
        # NOTE: Liabilities are negative (bug that turned into a feature)
        new_liabilities: -liabilities[:new_receipts],
        value: assets[:total] + liabilities[:total],
        change: assets[:new_receipts] + liabilities[:new_receipts],
      )
  end

  private def validate_reporting_currency_exchange_matrix
    exchange_rate_matrix = ExchangeRateMatrixQuery
      .new
      .owner_id(current_user.id)
      .to_currency_id(reporting_currency.id)
      .rate.is_nil

    return if exchange_rate_matrix.size == 0

    conversions = exchange_rate_matrix
      .map { |matrix| "#{matrix.from_currency_name} (#{matrix.from_currency_symbol}) => #{matrix.to_currency_name} (#{matrix.to_currency_symbol})" }
      .join(", ")

    flash.set("warning", "You may be viewing innacurate reports due to missing currency conversions: #{conversions}")
  end

  private def total_balance(
    report : Reports::CumulativeAccountBalanceQuery,
    account_type_name : String,
  ) : NamedTuple(total: Float64, new_receipts: Float64)
    report
      .select { |account| account.account_type_name == account_type_name }
      .reduce({total: 0.0.to_f64, new_receipts: 0.0.to_f64}) do |accum, account|
        {
          total:        account.balance.to_f64 + accum[:total],
          new_receipts: account.net_receipts.to_f64 + accum[:new_receipts],
        }
      end
  end
end
