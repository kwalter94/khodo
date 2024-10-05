class MonthlySavingsReport < BaseModel
  view :monthly_savings_report do
    column month : String
    column currency_name : String
    column currency_symbol : String
    column income : Float64?
    column expenses : Float64?
    column savings : Float64?
    column period : Int64

    belongs_to user : User
    belongs_to currency : Currency
  end
end
