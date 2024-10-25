class MakeUserPropertiesCurrencyIdOptional::V20241025170817 < Avram::Migrator::Migration::V1
  def migrate
    make_optional table_for(UserProperties), :currency_id
  end

  def rollback
    make_required table_for(UserProperties), :currency_id
  end
end
