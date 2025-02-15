class SaveUserProperties < UserProperties::SaveOperation
  # To save user provided params to the database, you must permit them
  # https://luckyframework.org/guides/database/saving-records#perma-permitting-columns
  needs user : User # ameba:disable Lint/UselessAssign
  permit_columns currency_id

  before_save do
    user_id.value = user.id
  end
end
