class LocalisedCumulativeAssetsReport < BaseModel
  view :localised_cumulative_assets_report do
    column month : String
    column account_name : String
    column currency_name : String
    column currency_symbol : String
    column receipts : Float64
    column deductions : Float64
    column net_receipts : Float64
    column cumulative_receipts : Float64
    column cumulative_deductions : Float64
    column total_assets : Float64
    column period : Int64
  end
end
