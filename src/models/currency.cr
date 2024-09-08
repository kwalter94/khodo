class Currency < BaseModel
  table do
    column name : String
    column symbol : String

    belongs_to user : User, foreign_key: :owner_id
  end
end
