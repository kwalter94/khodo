class CreateUserProperties::V20240922170655 < Avram::Migrator::Migration::V1
  def migrate
    # Learn about migrations at: https://luckyframework.org/guides/database/migrations
    create table_for(UserProperties) do
      primary_key id : Int64
      add_belongs_to currency : Currency, on_delete: :nullify
      add_belongs_to user : User, unique: true, on_delete: :cascade
      add_timestamps
    end
  end

  def rollback
    drop table_for(UserProperties)
  end
end
