class CallbacksController < Devise::OmniauthCallbacksController
  def github
    @person = Person.from_omniauth(request.env["omniauth.auth"])
    sign_in_and_redirect @person
  end
end
