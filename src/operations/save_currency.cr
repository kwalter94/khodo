class SaveCurrency < Currency::SaveOperation
  needs owner : User
  permit_columns name, symbol

  before_save do
    owner_id.value = owner.id
  end
end
