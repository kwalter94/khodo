class SaveLedgerAccountTypes < LedgerAccountTypes::SaveOperation
  # To save user provided params to the database, you must permit them
  # https://luckyframework.org/guides/database/saving-records#perma-permitting-columns
  #
  needs user : User # ameba:disable Lint/UselessAssign
  permit_columns ledger_id, account_type_id

  before_save do
    owner_id.value = user.id
  end
end
