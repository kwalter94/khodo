class TransactionTag < BaseModel
  table do
    belongs_to transaction : Transaction
    belongs_to tag : Tag
    belongs_to owner : User
  end
end
