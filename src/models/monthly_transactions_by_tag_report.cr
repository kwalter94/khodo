class MonthlyTransactionsByTagReport < BaseModel
  view :monthly_transactions_by_tag_report do
    column month : String
    column tag_id : Int64
    column tag_name : String
    column total_income : Float64
    column total_expenses : Float64
    column currency_id : Int64
    column currency_name : String
    column currency_symbol : String
    column period : Int64
    column user_id : Int64
  end
end
