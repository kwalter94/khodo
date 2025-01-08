class MonthlyTransactionsByTagReport < BaseModel
  view :monthly_transactions_by_tag_report do
    column month : String           # ameba:disable Lint/UselessAssign
    column tag_id : Int64           # ameba:disable Lint/UselessAssign
    column tag_name : String        # ameba:disable Lint/UselessAssign
    column total_income : Float64   # ameba:disable Lint/UselessAssign
    column total_expenses : Float64 # ameba:disable Lint/UselessAssign
    column currency_id : Int64      # ameba:disable Lint/UselessAssign
    column currency_name : String   # ameba:disable Lint/UselessAssign
    column currency_symbol : String # ameba:disable Lint/UselessAssign
    column period : Int64           # ameba:disable Lint/UselessAssign
    column user_id : Int64          # ameba:disable Lint/UselessAssign
  end
end
