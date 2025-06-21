class ElectionsController < ApplicationController
  before_action :set_election, only: %i[ show edit update destroy ]

  def index
    elections_scope = Election.includes(:office, :candidates, :candidacies)
    elections_scope = elections_scope.where(office_id: params[:office_id]) if params[:office_id]
    @pagy, @elections = pagy(elections_scope)
    render Views::Elections::IndexView.new(elections: @elections, pagy: @pagy, notice: notice)
  end

  def show
    render Views::Elections::ShowView.new(election: @election, notice: notice)
  end

  def new
    @election = Election.new
    render Views::Elections::NewView.new(election: @election)
  end

  def edit
    render Views::Elections::EditView.new(election: @election)
  end

  def create
    @election = Election.new(election_params)

    if @election.save
      redirect_to @election, notice: "Election was successfully created."
    else
      render Views::Elections::NewView.new(election: @election), status: :unprocessable_entity
    end
  end

  def update
    if @election.update(election_params)
      redirect_to @election, notice: "Election was successfully updated.", status: :see_other
    else
      render Views::Elections::EditView.new(election: @election), status: :unprocessable_entity
    end
  end

  def destroy
    @election.destroy!
    redirect_to elections_url, notice: "Election was successfully destroyed.", status: :see_other
  end

  private

  def set_election
    @election = Election.includes(:office, :candidates, :candidacies).find(params[:id])
  end

  def election_params
    params.require(:election).permit(:election_date, :status, :description, :is_mock, :is_historical)
  end
end