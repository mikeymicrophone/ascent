# Base class for application policies
class ApplicationPolicy < ActionPolicy::Base
  # Configure authorization contexts
  # We only use :voter, not the default :user
  authorize :voter, optional: true

  private

  # Define shared methods useful for most policies.
  # For example:
  #
  #  def owner?
  #    record.voter_id == voter.id
  #  end
end
