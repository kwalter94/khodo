class ExchangeRate < BaseModel
  table do
    belongs_to from_currency : Currency
    belongs_to to_currency : Currency
    column rate : Float64

    belongs_to owner : User
  end
end
