class MonthlySavingsReport < BaseModel
  view :monthly_savings_report do
    column month : String           # ameba:disable Lint/UselessAssign
    column currency_name : String   # ameba:disable Lint/UselessAssign
    column currency_symbol : String # ameba:disable Lint/UselessAssign
    column income : Float64?        # ameba:disable Lint/UselessAssign
    column expenses : Float64?      # ameba:disable Lint/UselessAssign
    column savings : Float64?       # ameba:disable Lint/UselessAssign
    column period : Int64           # ameba:disable Lint/UselessAssign

    belongs_to user : User         # ameba:disable Lint/UselessAssign
    belongs_to currency : Currency # ameba:disable Lint/UselessAssign
  end
end
