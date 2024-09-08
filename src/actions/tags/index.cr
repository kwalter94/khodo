class Tags::Index < BrowserAction
  get "/tags" do
    html IndexPage, tags: TagQuery.new.owner_id(current_user.id)
  end
end
