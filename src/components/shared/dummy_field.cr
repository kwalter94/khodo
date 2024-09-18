class Shared::DummyField < BaseComponent
  include Lucky::CatchUnpermittedAttribute

  needs label_text : String
  needs input_value : String

  def render(&)
    input_name = Random.new.base64

    div class: "mb-3 row" do
      label for: input_name, class: "col-md-2 col-form-label" do
        text label_text
      end

      div class: "col-md-10" do
        tag_defaults(
          name: input_name,
          class: "form-control",
          value: input_value,
          attrs: [:disabled]
        ) { |tag_builder| yield tag_builder }
      end
    end
  end

  def render
    render do |html|
      html.input type: "text"
    end
  end
end
