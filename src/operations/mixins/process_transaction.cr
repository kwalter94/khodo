module ProcessTransaction
  macro included
    needs owner : User

    permit_columns description, transaction_date, external_id
    attribute tags : Array(Int64)

    before_save do
      owner_id.value = owner.id
    end

    after_save do |transaction|
      TransactionTagQuery
        .new
        .transaction_id(transaction.id)
        .delete!

      tags.value.try do |tag_ids|
        TagQuery.new.id.in(tag_ids).each do |tag|
          SaveTransactionTag.create!(owner: owner, transaction: transaction, tag: tag)
        end
      end
    end
  end

  def validate_transaction
    validate_required description
    validate_required from_account_id
    validate_required from_amount
    validate_required to_account_id
    validate_required to_amount
    validate_required transaction_date

    validate_numeric from_amount, at_least: 0.01.to_f64
    validate_numeric to_amount, at_least: 0.01.to_f64

    validate_source_and_destination_accounts
    validate_accounts_ownership
    validate_exchange_rate
    validate_tags
  end

  def current_user_accounts : Enumerable(Account)
    AccountQuery
      .new
      .preload_currency
      .owner_id(owner.id)
      .where_type(AccountTypeQuery.new.name.in(["Asset", "Liability"]))
  end

  def current_user_tags : Enumerable(Tag)
    TagQuery.new.owner_id(owner.id).name.asc_order
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

  private def validate_tags
    tags.add_error("at least one tag is required") if tags.value.try(&.empty?)
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
