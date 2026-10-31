class InvitesController < ApplicationController
  def index
    influencers = Voter.influencers.with_invite_counts.order(Arel.sql("invite_count DESC"), :id)
    @pagy, @influencers = pagy(influencers)
    connected_ids = current_voter ? current_voter.received_invites.pluck(:inviter_id) : []
    render Views::Invites::IndexView.new(influencers: @influencers, pagy: @pagy, connected_ids: connected_ids)
  end

  def show
    response.headers["Cache-Control"] = "no-store"
    if voter_signed_in?
      redirect_to root_path
    else
      session["devise.inviter_id"] = Voter.find_by!(invite_token: params[:token]).id
      redirect_to new_voter_registration_path
    end
  end

  def create
    inviter = Voter.influencers.where(public_influencer: true).find_by!(invite_token: params[:token])
    if inviter == current_voter
      redirect_to invites_path, alert: "You cannot connect to yourself.", status: :see_other
      return
    end

    current_voter.received_invites.find_or_create_by!(inviter: inviter)
    destination = params[:source] == "influencer" ? influencer_path(token: inviter.invite_token) : invites_path
    redirect_to destination, notice: "You are now connected to this influencer.", status: :see_other
  end
end
