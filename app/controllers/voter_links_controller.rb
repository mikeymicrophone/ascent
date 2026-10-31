class VoterLinksController < ApplicationController
  def create
    link = current_voter.voter_links.new(link_params)
    if link.save
      redirect_to influencer_profile_path(anchor: "links"), notice: "Link added.", status: :see_other
    else
      render Views::InfluencerProfiles::ShowView.new(voter: current_voter, invalid_item: link), status: :unprocessable_content
    end
  end

  def update
    link = current_voter.voter_links.find(params[:id])
    if link.update(link_params)
      redirect_to influencer_profile_path(anchor: "links"), notice: "Link saved.", status: :see_other
    else
      render Views::InfluencerProfiles::ShowView.new(voter: current_voter, invalid_item: link), status: :unprocessable_content
    end
  end

  def move
    return head :bad_request unless %w[up down].include?(params[:direction])

    current_voter.voter_links.find(params[:id]).move!(params[:direction])
    redirect_to influencer_profile_path(anchor: "links"), status: :see_other
  end

  private

  def link_params
    params.require(:voter_link).permit(:label, :url, :active)
  end
end
