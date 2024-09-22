class SaveExchangeRate < ExchangeRate::SaveOperation
  # To save user provided params to the database, you must permit them
  # https://luckyframework.org/guides/database/saving-records#perma-permitting-columns
  permit_columns from_currency_id, to_currency_id, rate
end
