class Currency < BaseModel
  table do
    column name : String   # ameba:disable Lint/UselessAssign
    column symbol : String # ameba:disable Lint/UselessAssign

    belongs_to user : User, foreign_key: :owner_id # ameba:disable Lint/UselessAssign
  end
end
