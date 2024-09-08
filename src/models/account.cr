class Account < BaseModel
  table do
    column name : String

    belongs_to type : AccountType, foreign_key: :type_id
    belongs_to currency : Currency
    belongs_to owner : User, foreign_key: :owner_id

    has_many to_transactions : Transaction, foreign_key: :to_account_id
    has_many from_transactions : Transaction, foreign_key: :from_account_id
  end

  def display_name : String
    "#{name} (#{currency.name})"
  end
end
