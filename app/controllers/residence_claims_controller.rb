# A voter sets where they live: find the place by location or search, confirm what it puts on their
# ballot, then save it. Locations arrive in a POST body and are never stored.
class ResidenceClaimsController < ApplicationController
  PLACE_RESULTS = 12

  before_action { authorize! :residence_claim }

  def new
    query = params[:q].to_s.strip
    render Views::ResidenceClaims::NewView.new(query: query, places: query.present? ? places_named(query) : [],
      residences: current_voter.current_residences.includes(:jurisdiction).to_a)
  end

  def preview
    render Views::ResidenceClaims::PreviewView.new(claim: claim)
  end

  def create
    residence = claim.save!
    redirect_to ballot_path, notice: "#{claim.moving ? "You live in" : "You also live in"} #{residence.jurisdiction.name} now. Your ballot shows its races."
  rescue ActiveModel::ValidationError
    render Views::ResidenceClaims::PreviewView.new(claim: claim), status: :unprocessable_content
  end

  private

  def claim
    @claim ||= ResidenceClaim.new(**claim_params, voter: current_voter)
  end

  def claim_params
    params.permit(:latitude, :longitude, :jurisdiction_id, :moving, :county_id, :congressional_district_id, :state_senate_district_id, :state_house_district_id)
      .to_h.symbolize_keys.compact_blank
  end

  def places_named(query)
    Jurisdiction.named_like(query).where(jurisdictionable_type: %w[Municipality County])
      .includes(jurisdictionable: :state).limit(PLACE_RESULTS).sort_by { [ it.name, it.place_description ] }
  end
end
