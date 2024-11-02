class SignUps::NewPage < AuthLayout
  needs operation : SignUpUser

  def content
    div class: "row" { h1 "Sign Up" }
    div class: "row" { render_sign_up_form(@operation) }
    div class: "row" { link "Sign in instead", to: SignIns::New }
  end

  private def render_sign_up_form(op)
    div class: "col col-12" do
      form_for SignUps::Create do
        sign_up_fields(op)
        mount Shared::SubmitButton, "Sign Up", data_disable_with: "Signing Up"
      end
    end
  end

  private def sign_up_fields(op)
    mount Shared::Field, attribute: op.email, label_text: "Email", &.email_input(autofocus: "true")
    mount Shared::Field, attribute: op.password, label_text: "Password", &.password_input
    mount Shared::Field, attribute: op.password_confirmation, label_text: "Confirm Password", &.password_input
  end
end
