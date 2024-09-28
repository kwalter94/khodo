class FillUserProperties::V20240928192525 < Avram::Migrator::Migration::V1
  def migrate
    UserQuery.new.each do |user|
      currency = CurrencyQuery.new.owner_id(user.id).created_at.asc_order.first
      SaveUserProperties.create!(user: user, currency_id: currency.try(&.id))
    end
  end

  def rollback
    UserPropertiesQuery.new.delete!
  end
end
