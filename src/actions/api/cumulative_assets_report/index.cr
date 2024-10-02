class CumulativeAssetsReport::Index < BrowserAction
  get "/api/cumulative_assets_report" do
    query = LocalisedCumulativeAssetsReportQuery
      .new
      .owner_id(current_user.id)
      .month.asc_order

    json CumulativeAssetsReportSerializer.for_collection(query)
  end
end
