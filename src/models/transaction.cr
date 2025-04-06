class Transaction < BaseModel
  module TransactionLike
    abstract def from_account_id : Int64
    abstract def from_amount : Float64
    abstract def to_account_id : Int64
    abstract def to_amount : Float64
    abstract def transaction_date : Time
  end

  include TransactionLike

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

  def type : String
    if to_account.type.name == "Expense"
      "Expense"
    elsif from_account.type.name == "Income"
      "Income"
    else
      "Swap"
    end
  end
end
