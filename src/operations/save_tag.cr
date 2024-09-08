class SaveTag < Tag::SaveOperation
  # To save user provided params to the database, you must permit them
  # https://luckyframework.org/guides/database/saving-records#perma-permitting-columns
  needs owner : User
  permit_columns name, description

  before_save do
    owner_id.value = owner.id
  end

  before_save do
    validate_required name
  end
end
