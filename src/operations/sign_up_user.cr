class SignUpUser < User::SaveOperation
  param_key :user
  # Change password validations in src/operations/mixins/password_validations.cr
  include PasswordValidations

  permit_columns email
  attribute password : String              # ameba:disable Lint/UselessAssign
  attribute password_confirmation : String # ameba:disable Lint/UselessAssign

  before_save do
    validate_uniqueness_of email
    Authentic.copy_and_encrypt(password, to: encrypted_password) if password.valid?
  end

  after_save do |user|
    SaveUserProperties.create!(user: user)
    SignUpUser.create_default_ledgers(user)
  end

  def self.create_default_ledgers(user : User) : Enumerable(Ledger)
    liability = liability_account_type.id
    asset = asset_account_type.id

    [
      SaveLedger.create!(
        name: "General",
        description: "Default ledger for any uncategorised accounts",
        account_types: [liability, asset],
        user: user,
      ),
      SaveLedger.create!(
        name: "Creditors",
        description: "Accounts on what you owe others",
        account_types: [liability],
        user: user,
      ),
      SaveLedger.create!(
        name: "Debtors",
        description: "Accounts on what you are owed",
        account_types: [asset],
        user: user,
      ),
    ]
  end

  private def self.liability_account_type : AccountType
    AccountTypeQuery.new.name("Liability").first
  end

  private def self.asset_account_type : AccountType
    AccountTypeQuery.new.name("Asset").first
  end
end
