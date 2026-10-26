class MockElectionsController < ApplicationController
  def create
    authorize! :mock_election
    election = MockElection.new(**mock_election_params, creator: current_voter).save!
    redirect_to election_path(election), notice: "Mock election created."
  rescue ActiveModel::ValidationError, ActiveRecord::RecordInvalid => e
    redirect_back_or_to elections_path, alert: "Could not create the mock election: #{e.message}"
  end

  def destroy
    election = Election.find(params.expect(:id))
    authorize! election, with: MockElectionPolicy
    election.destroy_mock!
    redirect_to elections_path, notice: "Mock election removed."
  end

  private

  def mock_election_params
    params.expect(mock_election: [ :name, :description, :election_date, :jurisdiction_id, races: [ [ :title, candidates: [] ] ] ])
      .to_h.symbolize_keys
  end
end
