class TransactionTag < BaseModel
  table do
    belongs_to transaction : Transaction # ameba:disable Lint/UselessAssign
    belongs_to tag : Tag                 # ameba:disable Lint/UselessAssign
    belongs_to owner : User              # ameba:disable Lint/UselessAssign
  end
end
