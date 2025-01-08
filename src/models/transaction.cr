class Transaction < BaseModel
  table do
    column external_id : String?   # ameba:disable Lint/UselessAssign
    column description : String    # ameba:disable Lint/UselessAssign
    column from_amount : Float64   # ameba:disable Lint/UselessAssign
    column to_amount : Float64     # ameba:disable Lint/UselessAssign
    column transaction_date : Time # ameba:disable Lint/UselessAssign

    belongs_to from_account : Account, foreign_key: :from_account_id # ameba:disable Lint/UselessAssign
    belongs_to to_account : Account, foreign_key: :to_account_id     # ameba:disable Lint/UselessAssign
    belongs_to owner : User                                          # ameba:disable Lint/UselessAssign

    has_many transaction_tags : TransactionTag              # ameba:disable Lint/UselessAssign
    has_many tags : Tag, through: [:transaction_tags, :tag] # ameba:disable Lint/UselessAssign
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
