class Tags::Edit < BrowserAction
  get "/tags/:tag_id/edit" do
    tag = TagQuery.new.owner_id(current_user.id).find(tag_id)
    html EditPage,
      operation: SaveTag.new(tag, owner: current_user),
      tag: tag
  end
end
