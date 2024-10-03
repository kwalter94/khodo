class ExchangeRateMatrix < BaseModel
  view :exchange_rate_matrix do
    column from_currency_name : String
    column from_currency_symbol : String
    belongs_to from_currency : Currency
    column to_currency_name : String
    column to_currency_symbol : String
    belongs_to to_currency : Currency
    column rate : Float64?

    belongs_to owner : User
  end
end
