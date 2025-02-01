class LedgerAccountTypes < BaseModel
  table do
    belongs_to ledger : Ledger            # ameba:disable Lint/UselessAssign
    belongs_to account_type : AccountType # ameba:disable Lint/UselessAssign
    belongs_to owner : User               # ameba:disable Lint/UselessAssign
  end
end
