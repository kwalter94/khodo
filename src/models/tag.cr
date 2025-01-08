class Tag < BaseModel
  table do
    column name : String         # ameba:disable Lint/UselessAssign
    column description : String? # ameba:disable Lint/UselessAssign
    column external_id : String? # ameba:disable Lint/UselessAssign

    belongs_to owner : User # ameba:disable Lint/UselessAssign

    has_many transaction_tags : TransactionTag                                      # ameba:disable Lint/UselessAssign
    has_many transactions : Transaction, through: [:transaction_tags, :transaction] # ameba:disable Lint/UselessAssign
  end
end
