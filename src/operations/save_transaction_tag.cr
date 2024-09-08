class SaveTransactionTag < TransactionTag::SaveOperation
  # To save user provided params to the database, you must permit them
  # https://luckyframework.org/guides/database/saving-records#perma-permitting-columns
  needs owner : User
  needs transaction : Transaction
  needs tag : Tag

  before_save do
    validate_ownership
  end

  before_save do
    owner_id.value = owner.id
    transaction_id.value = transaction.id
    tag_id.value = tag.id
  end

  private def validate_ownership
    transaction_id.add_error("does not belong to current user") if owner.id != transaction.owner_id
    tag_id.add_error("does not belong to current user") if owner.id != tag.owner_id
  end
end
