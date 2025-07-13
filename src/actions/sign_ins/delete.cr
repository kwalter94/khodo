class SignIns::Delete < BrowserAction
  skip require_reporting_currency

  delete "/sign_out" do
    sign_out
    flash.info = "You have been signed out"
    redirect to: SignIns::New
  end
end
