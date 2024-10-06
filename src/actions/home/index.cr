class Home::Index < BrowserAction
  # include Auth::AllowGuests

  param currency_id : Int64? = nil

  get "/" do
    currency = find_reporting_currency
    if currency.nil?
      flash.info = "You need to set a default currency first!"
      return redirect to: UserProperties::Edit
    end

    flash_missing_currencies(currency)
    total_assets, new_assets = net_assets(currency)

    html Home::IndexPage,
      reporting_currency: currency,
      currencies: user_currencies,
      total_assets: total_assets,
      new_assets: new_assets
  end

  private def find_reporting_currency : Currency?
    currency = currency_id.try do |id|
      CurrencyQuery.new.owner_id(current_user.id).find(id)
    end

    currency || CurrencyQuery.find_user_default_currency?(current_user.id)
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

  private def net_assets(currency : Currency) : Tuple(Float64, Float64)
    assets_query = CumulativeAssetsReportQuery
      .new
      .owner_id(current_user.id)
      .currency_id(currency.id)
      .month.desc_order
      .total_assets.asc_order
      .period(1)

    assets_query.reduce({0.0.to_f64, 0.0.to_f64}) do |accum, asset|
      {(asset.total_assets || 0.0) + accum[0], (asset.net_receipts || 0.0)}
    end
  end

  private def user_currencies : Enumerable(Currency)
    CurrencyQuery.new.owner_id(current_user.id)
  end
end
