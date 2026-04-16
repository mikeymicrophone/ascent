class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Include Pagy backend for pagination support
  include Pagy::Backend

  # Include ActionPolicy authorization
  include ActionPolicy::Controller
  authorize :voter, through: :current_voter
  append_before_action :authorize_action_policy_resource!

  # Make current_voter available as a helper method in views
  helper_method :current_voter
  helper_method :current_user

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  rescue_from ActionPolicy::Unauthorized, with: :handle_unauthorized!

  def default_authorization_policy_class
    ApplicationRecordPolicy
  end

  def configure_permitted_parameters
    # For sign up
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])

    # Optional: for account update
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
  end

  def current_user
    current_voter
  end

  def authorize_action_policy_resource!
    return if devise_controller?

    target = action_policy_target
    return unless target

    authorize! target, to: action_policy_rule
  end

  def action_policy_target
    klass = controller_name.classify.safe_constantize
    return unless klass

    case action_name
    when "index", "new", "create"
      klass
    when "show", "edit", "update", "destroy"
      klass.find(params[:id])
    end
  end

  def action_policy_rule
    "#{action_name}?".to_sym
  end

  def handle_unauthorized!(_exception)
    destination = current_voter ? root_path : new_voter_session_path
    message = current_voter ? "You are not authorized to perform that action." : "Please sign in to continue."

    redirect_to destination, alert: message
  end
end
