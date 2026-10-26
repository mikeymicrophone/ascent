class MockElectionsController < ApplicationController
  def new
    authorize! :mock_election
    render Views::MockElections::NewView.new(mock_election: MockElection.new(election_date: 2.weeks.from_now.to_date), places: places)
  end

  def create
    authorize! :mock_election
    election = MockElection.new(**mock_election_params, creator: current_voter).save!
    redirect_to election_path(election), notice: "Mock election created."
  rescue ActiveModel::ValidationError, ActiveRecord::RecordInvalid => e
    redirect_to new_mock_election_path, alert: "Could not create the mock election: #{e.message}"
  end

  def destroy
    election = Election.find(params.expect(:id))
    authorize! election, with: MockElectionPolicy
    election.destroy_mock!
    redirect_to elections_path, notice: "Mock election removed."
  end

  private

  # The form lists candidates one per line; races left blank are dropped.
  def mock_election_params
    attributes = params.expect(mock_election: [ :name, :description, :election_date, :jurisdiction_id, races: [ [ :title, :candidates ] ] ]).to_h.symbolize_keys
    attributes.merge(races: Array(attributes[:races]).map { { title: it["title"], candidates: it["candidates"].to_s.lines.map(&:strip) } }
      .reject { it[:title].blank? && it[:candidates].compact_blank.empty? })
  end

  # The places a mock election can be set in: a place the voter came from first, then where they live
  # and every jurisdiction above it, or the states and countries when we don't know where they live.
  def places
    residence = current_voter.current_residence
    places = residence ? residence.ballot_jurisdictions : Jurisdiction.where(jurisdictionable_type: %w[State Country])
    [ Jurisdiction.find_by(id: params[:jurisdiction_id]), *places.includes(:jurisdictionable).sort_by(&:name) ].compact.uniq
  end
end
