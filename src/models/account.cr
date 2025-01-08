class Account < BaseModel
  table do
    column name : String # ameba:disable Lint/UselessAssign

    belongs_to type : AccountType, foreign_key: :type_id # ameba:disable Lint/UselessAssign
    belongs_to currency : Currency                       # ameba:disable Lint/UselessAssign
    belongs_to owner : User, foreign_key: :owner_id      # ameba:disable Lint/UselessAssign

    has_many to_transactions : Transaction, foreign_key: :to_account_id     # ameba:disable Lint/UselessAssign
    has_many from_transactions : Transaction, foreign_key: :from_account_id # ameba:disable Lint/UselessAssign
  end

  def display_name : String
    "#{name} (#{currency.name})"
  end
end
