class AddAccountsToUserGeneralLedgers::V20250128173645 < Avram::Migrator::Migration::V1
  def migrate
    LedgerQuery.new.name("General").each do |ledger|
      accounts = AccountQuery
        .new
        .owner_id(ledger.owner_id)
        .ledger_id
        .is_nil
        .preload_owner

      accounts.each do |account|
        SaveAccount.update!(
          account,
          owner: account.owner,
          ledger_id: ledger.id,
        )
      end
    end
  end

  def rollback
    accounts = AccountQuery
      .new
      .ledger_id
      .is_not_nil
      .preload_owner

    accounts.each do |account|
      SaveAccount.update!(
        account,
        owner: account.owner,
        ledger_id: nil,
      )
    end
  end
end
