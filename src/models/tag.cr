class Tag < BaseModel
  table do
    column name : String
    column description : String?

    belongs_to owner : User

    has_many transaction_tags : TransactionTag
    has_many transactions : Transaction, through: [:transaction_tags, :transaction]
  end
end
