class InfluencersController < ApplicationController
  skip_before_action :authorize_action_policy_resource!

  def show
    authorize! :influencer
    @influencer = Voter.influencers.where(public_influencer: true).visible_to(current_voter).find_by!(invite_token: params[:token])
    connected = current_voter&.received_invites&.exists?(inviter: @influencer) || false
    render Views::Influencers::ShowView.new(influencer: @influencer, connected: connected)
  end
end
