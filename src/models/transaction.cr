class Transaction < BaseModel
  table do
    column description : String
    column from_amount : Float64
    column to_amount : Float64
    column transaction_date : Time

    belongs_to from_account : Account, foreign_key: :from_account_id
    belongs_to to_account : Account, foreign_key: :to_account_id
    belongs_to owner : User

    has_many transaction_tags : TransactionTag
    has_many tags : Tag, through: [:transaction_tags, :tag]
  end

  def type(subject : Account) : String
    if from_account.type.name == "Income"
      "Income"
    elsif to_account.type.name == "Expense"
      "Expense"
    elsif from_account == subject
      "Transfer from"
    else
      "Transfer to"
    end
  end
end
