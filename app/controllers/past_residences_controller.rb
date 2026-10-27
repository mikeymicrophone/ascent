# A voter's residence history: where they live now and where they used to, each a town with its
# districts and dates. Past residences can be added and removed; a voter moves out of a place they live
# now, or claims a new one.
class PastResidencesController < ApplicationController
  PLACE_RESULTS = 12

  def index
    authorize! :past_residence
    query = params[:q].to_s.strip
    render Views::PastResidences::IndexView.new(residences: current_voter.residence_history.includes(*shown_places).to_a,
      query: query, places: query.present? ? places_named(query) : [])
  end

  def new
    authorize! :past_residence
    render Views::PastResidences::NewView.new(claim: claim)
  end

  def create
    authorize! :past_residence
    claim.save!
    redirect_to past_residences_path, notice: "Added #{claim.town.name} to where you've lived."
  rescue ActiveModel::ValidationError, ActiveRecord::RecordInvalid
    render Views::PastResidences::NewView.new(claim: claim), status: :unprocessable_content
  end

  def destroy
    residence = current_voter.residences.find(params.expect(:id))
    authorize! residence, with: PastResidencePolicy
    residence.destroy!
    redirect_to past_residences_path, notice: "Removed #{residence.jurisdiction.name} from where you've lived."
  end

  def move_out
    residence = current_voter.residences.find(params.expect(:id))
    authorize! residence, with: PastResidencePolicy
    current_voter.move_out_of!(residence)
    redirect_to past_residences_path, notice: "You moved out of #{residence.jurisdiction.name}. It's now a place you used to live."
  end

  private

  def claim
    @claim ||= ResidenceClaim.new(**claim_params, past: true, voter: current_voter)
  end

  def claim_params
    params.permit(:jurisdiction_id, :started_on, :ended_on, :county_id, :congressional_district_id, :state_senate_district_id, :state_house_district_id)
      .to_h.symbolize_keys.compact_blank
  end

  def shown_places
    [ { jurisdiction: [ :jurisdictionable, { parent: :jurisdictionable } ] }, :county, :congressional_district, :state_senate_district, :state_house_district ]
  end

  def places_named(query)
    Jurisdiction.named_like(query).where(jurisdictionable_type: %w[Municipality County])
      .includes(jurisdictionable: :state).limit(PLACE_RESULTS).sort_by { [ it.name, it.place_description ] }
  end
end
