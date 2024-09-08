class AccountBalanceReport < BaseModel
  view :account_balance_report do
    belongs_to account : Account
    belongs_to owner : User

    column name : String
    column currency_name : String
    column total_additions_last_month : Float64
    column total_deductions_last_month : Float64
    column net_additions_last_month : Float64
    column balance : Float64
  end
end
