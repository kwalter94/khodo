require "db"

module Reports
  class MonthlySavings
    include DB::Serializable

    property month : String
    property currency_id : Int64
    property currency_name : String
    property currency_symbol : String
    property income : Float64?
    property expenses : Float64?
    property savings : Float64?
    property period : Int64
    property user_id : Int64
  end
end
