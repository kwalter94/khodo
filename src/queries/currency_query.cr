class CurrencyQuery < Currency::BaseQuery
  Log = ::Log.for(self)

  def self.find_user_default_currency(user_id : Int64) : Currency
    currency = find_user_default_currency?(user_id)
    if currency.nil?
      raise UserProperties::ConfigurationError.new("Default currency not set!")
    end

    currency
  end

  def self.find_user_default_currency?(user_id : Int64) : Currency?
    Log.debug { "Fetching default currency for user ##{user_id}" }
    UserPropertiesQuery
      .new
      .preload_currency
      .user_id(user_id)
      .first?
      .try(&.currency)
  end

  def self.find_user_currencies(user_id : Int64) : CurrencyQuery
    CurrencyQuery.new.owner_id(user_id)
  end
end
