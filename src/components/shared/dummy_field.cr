class Shared::DummyField < BaseComponent
  include Lucky::CatchUnpermittedAttribute

  needs label_text : String   # ameba:disable Lint/UselessAssign
  needs input_value : String  # ameba:disable Lint/UselessAssign
  needs inline : Bool = false # ameba:disable Lint/UselessAssign

  def render(&)
    input_name = Random.new.base64

    if inline?
      label for: input_name, class: "col-md-2 col-form-label" do
        text label_text
      end

      div class: "col-md-4" do
        tag_defaults(name: input_name, class: "form-control", value: input_value, attrs: [:disabled]) do |tag_builder|
          yield tag_builder
        end
      end
    else
      div class: "mb-3 row" do
        label for: input_name, class: "col-md-2 col-form-label" do
          text label_text
        end

        div class: "col-md-10" do
          tag_defaults(name: input_name, class: "form-control", value: input_value, attrs: [:disabled]) do |tag_builder|
            yield tag_builder
          end
        end
      end
    end
  end

  def render
    render do |html|
      html.input type: "text"
    end
  end
end
