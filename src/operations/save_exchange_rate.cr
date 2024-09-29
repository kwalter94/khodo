class SaveExchangeRate < ExchangeRate::SaveOperation
  # To save user provided params to the database, you must permit them
  # https://luckyframework.org/guides/database/saving-records#perma-permitting-columns
  permit_columns from_currency_id, to_currency_id, rate
  needs owner : User

  before_save do
    owner_id.value = owner.id
  end

  before_save do
    validate_required from_currency_id
    validate_required to_currency_id
    validate_numeric rate, at_least: 0.0001

    validate_currencies
  end

  private def validate_currencies
    if from_currency_id.value == to_currency_id.value
      from_currency_id.add_error("Must be different from target currency")
      to_currency_id.add_error("Must be different from source currency")
      return
    end

    from_currency_id.value.try do |id|
      from_currency = CurrencyQuery.new.owner_id(owner.id).id(id).first?
      from_currency_id.add_error("Currency not found") if from_currency.nil?
    end

    to_currency_id.value.try do |id|
      to_currency = CurrencyQuery.new.owner_id(owner.id).id(id).first?
      to_currency_id.add_error("Currency not found") if to_currency.nil?
    end
  end
end
