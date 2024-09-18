class SignIns::NewPage < AuthLayout
  needs operation : SignInUser

  def content
    div class: "row" { h1 "Sign In", class: "col-12" }
    render_sign_in_form(@operation)
  end

  private def render_sign_in_form(op)
    div class: "row" do
      div class: "col-12" do
        form_for SignIns::Create, class: "form" do
          sign_in_fields(op)
          submit "Sign In", class: "btn btn-primary", flow_id: "sign-in-button"
        end
      end
    end

    div class: "row" do
      div class: "col-3" do
        link "Reset password", to: PasswordResetRequests::New
        text " | "
        link "Sign up", to: SignUps::New
      end
    end
  end

  private def sign_in_fields(op)
    mount Shared::Field, attribute: op.email, label_text: "Email", &.email_input(autofocus: "true")
    mount Shared::Field, attribute: op.password, label_text: "Password", &.password_input
  end
end
