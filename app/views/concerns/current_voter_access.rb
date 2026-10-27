# frozen_string_literal: true

# Gives components the signed-in voter from the controller's current_voter helper.
module CurrentVoterAccess
  extend ActiveSupport::Concern

  included do
    register_value_helper :current_voter
  end
end
