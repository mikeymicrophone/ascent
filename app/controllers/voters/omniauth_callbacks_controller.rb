# Google sends a voter back here after they choose an account.
class Voters::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    voter = Voter.from_google(request.env["omniauth.auth"])

    if voter.persisted?
      sign_in_and_redirect voter, event: :authentication
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    else
      redirect_to new_voter_registration_path, alert: "Could not sign in with Google: #{voter.errors.full_messages.to_sentence}"
    end
  end

  def failure
    redirect_to new_voter_session_path, alert: "Google sign-in did not finish. Please try again."
  end
end
