class SignIns::New < BrowserAction
  include Auth::RedirectSignedInUsers
  skip require_reporting_currency

  get "/sign_in" do
    html NewPage, operation: SignInUser.new
  end
end
