class CumulativeAccountBalanceReport < BaseModel
  view :cumulative_account_balance_report do
    column month : String
    column account_name : String
    column account_type_name : String
    column currency_name : String
    column currency_symbol : String
    column receipts : Float64
    column deductions : Float64
    column net_receipts : Float64
    column cumulative_receipts : Float64
    column cumulative_deductions : Float64
    column balance : Float64
    column period : Int64
    belongs_to owner : User
    belongs_to currency : Currency
    belongs_to account : Account
    belongs_to account_type : AccountType
  end
end
