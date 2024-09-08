class Tags::New < BrowserAction
  get "/tags/new" do
    html NewPage, operation: SaveTag.new(owner: current_user)
  end
end
