class Transaction < BaseModel
  table do
    column external_id : String?
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
    if subject == from_account && to_account.type.name == "Expense"
      "Expense"
    elsif subject == to_account && from_account.type.name == "Income"
      "Income"
    elsif subject.type.name == "Asset" || subject.type.name == "Liability"
      subject == from_account ? "Transfer from" : "Transfer to"
    elsif subject.type.name == "Expense"
      "Payment"
    elsif subject.type.name == "Income"
      "Receipt"
    else
      "Unknown"
    end
  end
end
