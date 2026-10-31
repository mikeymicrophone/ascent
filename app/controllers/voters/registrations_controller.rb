class Voters::RegistrationsController < Devise::RegistrationsController
  def build_resource(attributes = {})
    super
    resource.received_invites.build(inviter: inviting_voter) if inviting_voter
  end
end
