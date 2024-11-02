class Shared::SubmitButton < BaseComponent
  needs label : String = "Save"
  needs data_disable_with : String = "Submitting"

  def render
    div class: "d-grid" do
      submit label, class: "btn btn-primary", data_disable_with: data_disable_with
    end
  end
end
