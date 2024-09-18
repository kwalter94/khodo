class SaveExpense < Transaction::SaveOperation
  include ProcessTransaction

  needs account : Account

  permit_columns description, transaction_date, external_id
  attribute amount : Float64

  before_save do
    from_account_id.value = account.id
    to_account_id.value = find_or_create_expense_account(account.currency).id
    from_amount.value = amount.value
    to_amount.value = amount.value

    validate_transaction
  end

  private def find_or_create_expense_account(currency : Currency) : Account
    expense_type = AccountTypeQuery.new.name("Expense").first

    account = AccountQuery
      .new
      .currency_id(currency.id)
      .owner_id(owner.id)
      .type_id(expense_type.id)
      .first?

    return account if account

    SaveAccount.create!(
      name: "#{currency.name} Expenses",
      type_id: expense_type.id,
      currency_id: currency.id,
      owner: owner,
    )
  end
end
