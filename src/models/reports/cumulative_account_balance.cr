require "db"
require "pg"

module Reports
  class CumulativeAccountBalance
    include DB::Serializable

    property month : String
    property account_id : Int64
    property account_name : String
    property account_type_id : Int64
    property account_type_name : String
    property ledger_id : Int64
    property ledger_name : String
    property currency_id : Int64
    property currency_name : String
    property currency_symbol : String
    property receipts : Float64
    property deductions : Float64
    property net_receipts : Float64
    property cumulative_receipts : Float64
    property cumulative_deductions : Float64
    property balance : Float64
    property owner_id : Int64
    property period : Int64
  end
end
