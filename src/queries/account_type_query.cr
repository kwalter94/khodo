class AccountTypeQuery < AccountType::BaseQuery
  def self.user_managed_account_types : AccountTypeQuery
    AccountTypeQuery.new.name.in(["Asset", "Liability"])
  end

  def self.system_managed_account_types : AccountTypeQuery
    AccountTypeQuery.new.name.not_in(["Asset", "Liability"])
  end
end
