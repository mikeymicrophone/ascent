class Voters::RegistrationsController < Devise::RegistrationsController
  def create
    super { |voter| track_signup(voter, method: "email") if voter.persisted? }
  end

  def build_resource(attributes = {})
    super
    resource.received_invites.build(inviter: inviting_voter) if inviting_voter
  end
end
