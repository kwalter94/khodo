class Tags::Create < BrowserAction
  post "/tags" do
    SaveTag.create(params, owner: current_user) do |operation, tag|
      if tag
        flash.success = "The record has been saved"
        redirect Show.with(tag.id)
      else
        flash.failure = "It looks like the form is not valid"
        html NewPage, operation: operation
      end
    end
  end
end
