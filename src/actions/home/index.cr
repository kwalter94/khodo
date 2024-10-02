class Home::Index < BrowserAction
  # include Auth::AllowGuests

  param currency_id : Int64? = nil

  get "/" do
    fallback_currency = CurrencyQuery
      .new
      .owner_id(current_user.id)
      .created_at.asc_order
      .first?

    if !fallback_currency
      flash.info = "You need to create currencies first"
      return redirect to: Currencies::New
    end

    currency = currency_id.try { |id| CurrencyQuery.new.owner_id(current_user.id).find(id) }
    currency ||= UserPropertiesQuery
      .new
      .preload_currency
      .user_id(current_user.id)
      .first?
      .try(&.currency)
    currency ||= fallback_currency

    assets_query = LocalisedCumulativeAssetsReportQuery
      .new
      .owner_id(current_user.id)
      .month.desc_order
      .total_assets.asc_order

    total_assets, new_assets = net_assets(assets_query)

    html Home::IndexPage,
      currency: currency,
      assets_query: assets_query,
      total_assets: total_assets,
      new_assets: new_assets
  end

  private def net_assets(assets_query : LocalisedCumulativeAssetsReportQuery) : Tuple(Float64, Float64)
    assets_query
      .period(1)
      .reduce({0.0.to_f64, 0.0.to_f64}) { |accum, asset| {asset.total_assets + accum[0], asset.net_receipts} }
  end
end
