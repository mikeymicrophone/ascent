class VoterElectionBaselinesController < ApplicationController
  before_action :set_voter_election_baseline, only: %i[ show edit update destroy ]

  def index
    @voter_election_baselines = VoterElectionBaseline.all
    render Views::VoterElectionBaselines::IndexView.new(voter_election_baselines: @voter_election_baselines, notice: notice)
  end

  def show
    render Views::VoterElectionBaselines::ShowView.new(voter_election_baseline: @voter_election_baseline, notice: notice)
  end

  def new
    @voter_election_baseline = VoterElectionBaseline.new
    render Views::VoterElectionBaselines::NewView.new(voter_election_baseline: @voter_election_baseline)
  end

  def edit
    render Views::VoterElectionBaselines::EditView.new(voter_election_baseline: @voter_election_baseline)
  end

  def create
    @voter_election_baseline = VoterElectionBaseline.new(voter_election_baseline_params)

    if @voter_election_baseline.save
      redirect_to @voter_election_baseline, notice: "Voter election baseline was successfully created."
    else
      render Views::VoterElectionBaselines::NewView.new(voter_election_baseline: @voter_election_baseline), status: :unprocessable_entity
    end
  end

  def update
    if @voter_election_baseline.update(voter_election_baseline_params)
      redirect_to @voter_election_baseline, notice: "Voter election baseline was successfully updated.", status: :see_other
    else
      render Views::VoterElectionBaselines::EditView.new(voter_election_baseline: @voter_election_baseline), status: :unprocessable_entity
    end
  end

  def destroy
    @voter_election_baseline.destroy!
    redirect_to voter_election_baselines_url, notice: "Voter election baseline was successfully destroyed.", status: :see_other
  end

  private

  def set_voter_election_baseline
    @voter_election_baseline = VoterElectionBaseline.find(params[:id])
  end

  def voter_election_baseline_params
    params.require(:voter_election_baseline).permit(:baseline)
  end
end