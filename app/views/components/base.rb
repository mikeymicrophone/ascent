# frozen_string_literal: true

class Views::Components::Base < Phlex::HTML
  # Include all Rails view helpers to make them available in all components
  include ScaffoldUiHelper
  include Phlex::Rails::Helpers::DOMID
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::Rails::Helpers::CSRFMetaTags
  
  # Include ActionPolicy authorization helpers
  include ActionPolicy::Behaviour
  
  # Include current voter access
  include CurrentVoterAccess
  
  # You can add more helpers as needed:
  # include Phlex::Rails::Helpers::NumberHelper
  # include Phlex::Rails::Helpers::DateHelper

  private

  def default_authorization_policy_class
    ApplicationRecordPolicy
  end
end
