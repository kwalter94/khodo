class CumulativeAssetsReport::Index < BrowserAction
  param currency_id : Int64? = nil

  get "/api/cumulative_assets_report" do
    currency = currency_id.try do |id|
      CurrencyQuery
        .new
        .owner_id(current_user.id)
        .id(id)
        .first?
    end

    currency = CurrencyQuery.find_user_default_currency(current_user.id) if currency.nil?

    query = CumulativeAssetsReportQuery
      .new
      .owner_id(current_user.id)
      .currency_id(currency.id)
      .month.asc_order

    json CumulativeAssetsReportSerializer.for_collection(query)
  end
end
