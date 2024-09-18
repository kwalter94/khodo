class Tags::Index < BrowserAction
  get "/tags" do
    html IndexPage, tags: TagQuery.new.owner_id(current_user.id).name.asc_order
  end
end
