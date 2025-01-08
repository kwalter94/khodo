class ExchangeRateMatrix < BaseModel
  view :exchange_rate_matrix do
    column from_currency_name : String   # ameba:disable Lint/UselessAssign
    column from_currency_symbol : String # ameba:disable Lint/UselessAssign
    belongs_to from_currency : Currency  # ameba:disable Lint/UselessAssign
    column to_currency_name : String     # ameba:disable Lint/UselessAssign
    column to_currency_symbol : String   # ameba:disable Lint/UselessAssign
    belongs_to to_currency : Currency    # ameba:disable Lint/UselessAssign
    column rate : Float64?               # ameba:disable Lint/UselessAssign

    belongs_to owner : User # ameba:disable Lint/UselessAssign
  end
end
