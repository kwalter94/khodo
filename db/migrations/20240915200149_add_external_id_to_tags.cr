class AddExternalIdToTags::V20240915200149 < Avram::Migrator::Migration::V1
  def migrate
    alter table_for(Tag) do
      add external_id : String?
    end
  end

  def rollback
    alter table_for(Tag) do
      remove :external_id
    end
  end
end
