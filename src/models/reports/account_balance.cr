require "db"
require "pg"

module Reports
  class AccountBalance
    include DB::Serializable

    property account_id : Int64
    property account_name : String
    property currency_id : Int64
    property currency_name : String
    property currency_symbol : String
    property ledger_id : Int64
    property ledger_name : String
    property account_type_id : Int64
    property account_type_name : String
    property current_month_additions : PG::Numeric
    property current_month_deductions : PG::Numeric
    property current_month_net_additions : PG::Numeric
    property current_year_additions : PG::Numeric
    property current_year_deductions : PG::Numeric
    property current_year_net_additions : PG::Numeric
    property lifetime_additions : PG::Numeric
    property lifetime_deductions : PG::Numeric
    property balance : PG::Numeric
    property owner_id : Int64
  end
end
