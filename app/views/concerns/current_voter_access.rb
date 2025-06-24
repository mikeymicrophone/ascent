# frozen_string_literal: true

module CurrentVoterAccess
  extend ActiveSupport::Concern

  private

  def current_voter
    # Access current_voter from the view context
    # This works because Phlex components have access to the view context
    # which includes controller helper methods
    helpers.current_voter if helpers.respond_to?(:current_voter)
  rescue NoMethodError
    # Fallback to nil if current_voter is not available
    nil
  end
end