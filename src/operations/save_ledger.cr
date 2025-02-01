class SaveLedger < Ledger::SaveOperation
  # To save user provided params to the database, you must permit them
  # https://luckyframework.org/guides/database/saving-records#perma-permitting-columns
  needs user : User # ameba:disable Lint/UselessAssign
  permit_columns name, description
  attribute account_types : Array(Int64) # ameba:disable Lint/UselessAssign

  before_save do
    owner_id.value = user.id
  end

  after_save do |ledger|
    account_types.value.try do |types|
      types.each do |type_id|
        SaveLedgerAccountTypes.create!(
          ledger_id: ledger.id,
          account_type_id: type_id,
          user: user,
        )
      end
    end
  end
end
