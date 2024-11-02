class PasswordResetRequests::NewPage < AuthLayout
  needs operation : RequestPasswordReset

  def content
    h1 "Reset your password"
    render_form(@operation)
  end

  private def render_form(op)
    form_for PasswordResetRequests::Create do
      mount Shared::Field, attribute: op.email, label_text: "Email", &.email_input
      mount Shared::SubmitButton, "Reset Password", data_disable_with: "Resetting password"
    end
  end
end
