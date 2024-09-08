class SaveAccount < Account::SaveOperation
  # To save user provided params to the database, you must permit them
  # https://luckyframework.org/guides/database/saving-records#perma-permitting-columns
  needs owner : User
  permit_columns name, type_id, currency_id

  before_save do
    owner_id.value = owner.id
  end

  before_save do
    validate_required name
    validate_required type_id
    validate_required currency_id
  end

  def account_types : Enumerable(AccountType)
    AccountTypeQuery.new.name.in(["Asset", "Liability"])
  end

  def currencies : Enumerable(Currency)
    CurrencyQuery.new.owner_id(owner.id)
  end
end
