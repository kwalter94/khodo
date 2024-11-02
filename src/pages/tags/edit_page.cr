class Tags::EditPage < MainLayout
  needs operation : SaveTag
  needs tag : Tag
  quick_def page_title, "Edit Tag with id: #{tag.id}"

  def content
    div class: "row" { link "Back to #{tag.name}", Tags::Show.with(tag.id) }
    div class: "row" { h1 "Editting tag \"#{tag.name}\"" }
    div class: "row" { render_tag_form(operation) }
  end

  def render_tag_form(op)
    form_for Tags::Update.with(tag.id) do
      # Edit fields in src/components/tags/form_fields.cr
      mount Tags::FormFields, op
      mount Shared::SubmitButton, label: "Save", data_disable_with: "Saving Tag"
    end
  end
end
