class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Include Pagy backend for pagination support
  include Pagy::Backend

  # Include ActionPolicy authorization
  include ActionPolicy::Controller
  authorize :voter, through: :current_voter

  # Make current_voter available as a helper method in views
  helper_method :current_voter

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # For sign up
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])

    # Optional: for account update
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
  end
end
