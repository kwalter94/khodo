require "db"

module Reports
  class MonthlyTransactionsByTag
    include DB::Serializable

    property month : String
    property tag_id : Int64
    property tag_name : String
    property total_income : Float64
    property total_expenses : Float64
    property net_income : Float64
    property currency_id : Int64
    property currency_name : String
    property currency_symbol : String
    property period : Int64
    property user_id : Int64
  end
end
