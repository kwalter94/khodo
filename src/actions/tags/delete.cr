class Tags::Delete < BrowserAction
  delete "/tags/:tag_id" do
    tag = TagQuery.new.owner_id(current_user.id).find(tag_id)
    DeleteTag.delete(tag) do |_operation, _deleted|
      flash.success = "Deleted the tag"
      redirect Index
    end
  end
end
