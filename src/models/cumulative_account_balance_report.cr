class CumulativeAccountBalanceReport < BaseModel
  view :cumulative_account_balance_report do
    column month : String                  # ameba:disable Lint/UselessAssign
    column account_name : String           # ameba:disable Lint/UselessAssign
    column account_type_name : String      # ameba:disable Lint/UselessAssign
    column currency_name : String          # ameba:disable Lint/UselessAssign
    column currency_symbol : String        # ameba:disable Lint/UselessAssign
    column receipts : Float64              # ameba:disable Lint/UselessAssign
    column deductions : Float64            # ameba:disable Lint/UselessAssign
    column net_receipts : Float64          # ameba:disable Lint/UselessAssign
    column cumulative_receipts : Float64   # ameba:disable Lint/UselessAssign
    column cumulative_deductions : Float64 # ameba:disable Lint/UselessAssign
    column balance : Float64               # ameba:disable Lint/UselessAssign
    column period : Int64                  # ameba:disable Lint/UselessAssign
    belongs_to owner : User                # ameba:disable Lint/UselessAssign
    belongs_to currency : Currency         # ameba:disable Lint/UselessAssign
    belongs_to account : Account           # ameba:disable Lint/UselessAssign
    belongs_to account_type : AccountType  # ameba:disable Lint/UselessAssign
  end
end
