class InfluencerProfilesController < ApplicationController
  def show
    authorize! :influencer_profile
    render Views::InfluencerProfiles::ShowView.new(voter: current_voter)
  end
end
