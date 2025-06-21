class VotersController < ApplicationController
  before_action :set_voter, only: %i[ show edit update destroy ]

  def index
    voters_scope = Voter.with_voting_activity
    @pagy, @voters = pagy(voters_scope)
    render Views::Voters::IndexView.new(voters: @voters, pagy: @pagy, notice: notice)
  end

  def show
    render Views::Voters::ShowView.new(voter: @voter, notice: notice)
  end

  def new
    @voter = Voter.new
    render Views::Voters::NewView.new(voter: @voter)
  end

  def edit
    render Views::Voters::EditView.new(voter: @voter)
  end

  def create
    @voter = Voter.new(voter_params)

    if @voter.save
      redirect_to @voter, notice: "Voter was successfully created."
    else
      render Views::Voters::NewView.new(voter: @voter), status: :unprocessable_entity
    end
  end

  def update
    if @voter.update(voter_params)
      redirect_to @voter, notice: "Voter was successfully updated.", status: :see_other
    else
      render Views::Voters::EditView.new(voter: @voter), status: :unprocessable_entity
    end
  end

  def destroy
    @voter.destroy!
    redirect_to voters_url, notice: "Voter was successfully destroyed.", status: :see_other
  end

  private

  def set_voter
    @voter = Voter.with_voting_activity.find(params[:id])
  end

  def voter_params
    params.require(:voter).permit(:first_name, :last_name, :birth_date, :is_verified)
  end
end