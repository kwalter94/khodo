class AccountBalanceReport < BaseModel
  view :account_balance_report do
    belongs_to account : Account # ameba:disable Lint/UselessAssign
    belongs_to owner : User      # ameba:disable Lint/UselessAssign

    column name : String                         # ameba:disable Lint/UselessAssign
    column currency_name : String                # ameba:disable Lint/UselessAssign
    column total_additions_last_month : Float64  # ameba:disable Lint/UselessAssign
    column total_deductions_last_month : Float64 # ameba:disable Lint/UselessAssign
    column net_additions_last_month : Float64    # ameba:disable Lint/UselessAssign
    column balance : Float64                     # ameba:disable Lint/UselessAssign
  end
end
