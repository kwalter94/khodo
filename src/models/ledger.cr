class Ledger < BaseModel
  table do
    column name : String        # ameba:disable Lint/UselessAssign
    column description : String # ameba:disable Lint/UselessAssign

    belongs_to owner : User                                                               # ameba:disable Lint/UselessAssign
    has_many ledger_account_types : LedgerAccountTypes                                    # ameba:disable Lint/UselessAssign
    has_many account_types : AccountType, through: [:ledger_account_types, :account_type] # ameba:disable Lint/UselessAssign
  end
end
