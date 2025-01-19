class Shared::SubmitButton < BaseComponent
  needs label : String = "Save"                   # ameba:disable Lint/UselessAssign
  needs data_disable_with : String = "Submitting" # ameba:disable Lint/UselessAssign

  def render
    div class: "d-grid" do
      submit label, class: "btn btn-primary", data_disable_with: data_disable_with
    end
  end
end
