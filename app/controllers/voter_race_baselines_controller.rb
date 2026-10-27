class VoterRaceBaselinesController < ApplicationController
  before_action :set_voter_race_baseline, only: %i[ show edit update destroy ]

  def index
    @pagy, @voter_race_baselines = pagy(VoterRaceBaseline.all)
    render Views::VoterRaceBaselines::IndexView.new(voter_race_baselines: @voter_race_baselines, pagy: @pagy)
  end

  def show
    render Views::VoterRaceBaselines::ShowView.new(voter_race_baseline: @voter_race_baseline)
  end

  def new
    @voter_race_baseline = VoterRaceBaseline.new
    render Views::VoterRaceBaselines::NewView.new(voter_race_baseline: @voter_race_baseline)
  end

  def edit
    render Views::VoterRaceBaselines::EditView.new(voter_race_baseline: @voter_race_baseline)
  end

  def create
    @voter_race_baseline = VoterRaceBaseline.new(voter_race_baseline_params)

    if @voter_race_baseline.save
      redirect_to @voter_race_baseline, notice: "Voter race baseline was successfully created."
    else
      render Views::VoterRaceBaselines::NewView.new(voter_race_baseline: @voter_race_baseline), status: :unprocessable_entity
    end
  end

  def update
    if @voter_race_baseline.update(voter_race_baseline_params)
      redirect_to @voter_race_baseline, notice: "Voter race baseline was successfully updated.", status: :see_other
    else
      render Views::VoterRaceBaselines::EditView.new(voter_race_baseline: @voter_race_baseline), status: :unprocessable_entity
    end
  end

  def destroy
    @voter_race_baseline.destroy!
    redirect_to voter_race_baselines_url, notice: "Voter race baseline was successfully destroyed.", status: :see_other
  end

  private

  def set_voter_race_baseline
    @voter_race_baseline = VoterRaceBaseline.find(params[:id])
  end

  def voter_race_baseline_params
    params.require(:voter_race_baseline).permit(:voter_id, :race_id, :baseline)
  end
end
