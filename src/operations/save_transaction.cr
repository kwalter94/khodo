class SaveTransaction < Transaction::SaveOperation
  include ProcessTransaction

  permit_columns from_account_id, from_amount, to_account_id, to_amount

  before_save do
    validate_transaction
  end
end
