class Tags::Show < BrowserAction
  get "/tags/:tag_id" do
    html ShowPage, tag: TagQuery.new.owner_id(current_user.id).find(tag_id)
  end
end
