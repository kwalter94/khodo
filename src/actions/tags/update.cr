class Tags::Update < BrowserAction
  put "/tags/:tag_id" do
    tag = TagQuery.new.owner_id(current_user.id).find(tag_id)
    SaveTag.update(tag, params, owner: current_user) do |operation, updated_tag|
      if operation.saved?
        flash.success = "The record has been updated"
        redirect Tags::Show.with(tag.id)
      else
        flash.failure = "It looks like the form is not valid"
        html EditPage, operation: operation, tag: updated_tag
      end
    end
  end
end
