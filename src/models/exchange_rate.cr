class ExchangeRate < BaseModel
  table do
    belongs_to from_currency : Currency # ameba:disable Lint/UselessAssign
    belongs_to to_currency : Currency   # ameba:disable Lint/UselessAssign
    column rate : Float64               # ameba:disable Lint/UselessAssign

    belongs_to owner : User # ameba:disable Lint/UselessAssign
  end
end
