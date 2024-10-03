class Home::Index < BrowserAction
  # include Auth::AllowGuests

  param currency_id : Int64? = nil

  get "/" do
    currency = currency_id.try do |id|
      CurrencyQuery.new.owner_id(current_user.id).find(id)
    end
    currency = CurrencyQuery.find_user_default_currency?(current_user.id) if currency.nil?
    if currency.nil?
      flash.info = "You need to set a default currency first!"
      return redirect to: UserProperties::Edit
    end

    exchange_rate_matrix = ExchangeRateMatrixQuery
      .new
      .owner_id(current_user.id)
      .to_currency_id(currency.id)
      .rate.is_nil

    if exchange_rate_matrix.size > 0
      conversions = exchange_rate_matrix
        .map { |matrix| "#{matrix.from_currency_name} (#{matrix.from_currency_symbol}) => #{matrix.to_currency_name} (#{matrix.to_currency_symbol})" }
        .join(", ")
      flash.set("warning", "You may be viewing innacurate reports due to missing currency conversions: #{conversions}")
    end

    assets_query = CumulativeAssetsReportQuery
      .new
      .owner_id(current_user.id)
      .currency_id(currency.id)
      .month.desc_order
      .total_assets.asc_order

    total_assets, new_assets = net_assets(assets_query)

    html Home::IndexPage,
      currency: currency,
      assets_query: assets_query,
      total_assets: total_assets,
      new_assets: new_assets
  end

  private def net_assets(assets_query : CumulativeAssetsReportQuery) : Tuple(Float64, Float64)
    assets_query
      .period(1)
      .reduce({0.0.to_f64, 0.0.to_f64}) { |accum, asset| {(asset.total_assets || 0.0) + accum[0], (asset.net_receipts || 0.0)} }
  end
end
