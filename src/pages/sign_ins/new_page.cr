class SignIns::NewPage < AuthLayout
  needs operation : SignInUser

  def content
    div class: "row" { h1 "Sign In", class: "col-12" }
    div class: "row" { render_sign_in_form(@operation) }
    div class: "row" { footer }
  end

  private def render_sign_in_form(op)
    div class: "col-12" do
      form_for SignIns::Create, class: "form" do
        sign_in_fields(op)
        mount Shared::SubmitButton, "Sign In", data_disable_with: "Signing in"
      end
    end
  end

  private def sign_in_fields(op)
    mount Shared::Field, attribute: op.email, label_text: "Email", &.email_input(autofocus: "true")
    mount Shared::Field, attribute: op.password, label_text: "Password", &.password_input
  end

  private def footer
    div class: "col-3" do
      link "Reset password", to: PasswordResetRequests::New
      text " | "
      link "Sign up", to: SignUps::New
    end
  end
end
