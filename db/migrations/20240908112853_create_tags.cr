class CreateTags::V20240908112853 < Avram::Migrator::Migration::V1
  def migrate
    # Learn about migrations at: https://luckyframework.org/guides/database/migrations
    create table_for(Tag) do
      primary_key id : Int64
      add name : String, index: true
      add description : String?

      add_belongs_to owner : User, on_delete: :cascade

      add_timestamps
    end
  end

  def rollback
    drop table_for(Tag)
  end
end
