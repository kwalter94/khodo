class SaveIncome < Transaction::SaveOperation
  include ProcessTransaction

  needs account : Account

  permit_columns description, transaction_date, external_id
  attribute amount : Float64

  before_save do
    from_account_id.value = find_or_create_income_account(account.currency).id
    to_account_id.value = account.id
    from_amount.value = amount.value
    to_amount.value = amount.value

    validate_transaction
  end

  private def find_or_create_income_account(currency : Currency) : Account
    income_type = AccountTypeQuery.new.name("Income").first

    account = AccountQuery
      .new
      .currency_id(currency.id)
      .owner_id(owner.id)
      .type_id(income_type.id)
      .first?

    return account if account

    SaveAccount.create!(
      name: "#{currency.name} Income",
      type_id: income_type.id,
      currency_id: currency.id,
      owner: owner,
    )
  end
end
