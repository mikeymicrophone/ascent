module GovernmentBranch
  extend ActiveSupport::Concern

  BRANCHES = {
    legislative: 0,
    executive: 1,
    judicial: 2
  }.freeze

  included do
    enum :branch, BRANCHES, validate: { allow_nil: true }
  end
end
