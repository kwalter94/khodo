class SaveTransfer < Transaction::SaveOperation
  include ProcessTransaction

  needs account : Account # ameba:disable Lint/UselessAssign
  permit_columns description, from_account_id, from_amount, transaction_date, to_account_id, to_amount

  before_save do
    from_account_id.value = account.id

    validate_transaction
  end
end
