class SaveTransaction < Transaction::SaveOperation
  # To save user provided params to the database, you must permit them
  # https://luckyframework.org/guides/database/saving-records#perma-permitting-columns
  needs owner : User

  permit_columns description, from_account_id, from_amount, to_account_id, to_amount, transaction_date
  attribute tag_ids : Array(Int64)

  before_save do
    owner_id.value = owner.id
  end

  before_save do
    validate_required description
    validate_required from_account_id
    validate_required from_amount
    validate_required to_account_id
    validate_required to_amount
    validate_required transaction_date

    validate_numeric from_amount, greater_than: 0.to_f64
    validate_numeric to_amount, greater_than: 0.to_f64

    validate_source_and_destination_accounts
    validate_accounts_ownership
    validate_exchange_rate
  end

  after_save do |transaction|
    TransactionTagQuery.new.transaction_id(transaction.id).delete!

    tag_ids.value.try do |ids|
      TagQuery.new.id.in(ids).each do |tag|
        SaveTransactionTag.create!(owner: owner, transaction: transaction, tag: tag)
      end
    end
  end

  def accounts : Enumerable(Account)
    AccountQuery
      .new
      .preload_currency
      .owner_id(owner.id)
      .where_type(AccountTypeQuery.new.name.in(["Asset", "Liability"]))
  end

  def tags : Enumerable(Tag)
    TagQuery.new.owner_id(owner.id)
  end

  private def validate_accounts_ownership
    from_account_id.add_error("account does not exist") if from_account.nil?
    to_account_id.add_error("account does not exist") if to_account.nil?
  end

  private def validate_source_and_destination_accounts
    if from_account.try(&.id) == to_account.try(&.id)
      from_account_id.add_error("same as to account")
      to_account_id.add_error("same as from account")
    end
  end

  private def validate_exchange_rate
    from_account.try do |from|
      to_account.try do |to|
        if from.currency == to.currency && from_amount.value != to_amount.value
          from_amount.add_error("does not equal same currency to amount")
          to_amount.add_error("does not equal same currency from amount")
        end
      end
    end
  end

  @to_account : Account?
  @from_account : Account?

  private def to_account : Account?
    to_account_id.value.try do |account_id|
      @to_account ||= AccountQuery
        .new
        .preload_currency
        .owner_id(owner.id)
        .id(account_id)
        .first
    end
  end

  private def from_account : Account?
    from_account_id.value.try do |account_id|
      @from_account = AccountQuery
        .new
        .preload_currency
        .owner_id(owner.id)
        .id(account_id)
        .first
    end
  end
end
