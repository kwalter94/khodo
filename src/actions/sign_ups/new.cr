class SignUps::New < BrowserAction
  include Auth::RedirectSignedInUsers
  skip require_reporting_currency

  get "/sign_up" do
    html NewPage, operation: SignUpUser.new
  end
end
