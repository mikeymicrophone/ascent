class CandidaciesController < ApplicationController
  before_action :set_candidacy, only: %i[ show edit update destroy ]

  def index
    candidacies_scope = Candidacy.with_election_context
    candidacies_scope = candidacies_scope.where(person_id: params[:person_id]) if params[:person_id]
    candidacies_scope = candidacies_scope.where(race_id: params[:race_id]) if params[:race_id]
    @pagy, @candidacies = pagy(candidacies_scope)
    render Views::Candidacies::IndexView.new(candidacies: @candidacies, pagy: @pagy, notice: notice)
  end

  def show
    render Views::Candidacies::ShowView.new(candidacy: @candidacy, notice: notice)
  end

  def new
    @candidacy = Candidacy.new
    render Views::Candidacies::NewView.new(candidacy: @candidacy)
  end

  def edit
    render Views::Candidacies::EditView.new(candidacy: @candidacy)
  end

  def create
    @candidacy = Candidacy.new(candidacy_params)

    if @candidacy.save
      redirect_to @candidacy, notice: "Candidacy was successfully created."
    else
      render Views::Candidacies::NewView.new(candidacy: @candidacy), status: :unprocessable_entity
    end
  end

  def update
    if @candidacy.update(candidacy_params)
      redirect_to @candidacy, notice: "Candidacy was successfully updated.", status: :see_other
    else
      render Views::Candidacies::EditView.new(candidacy: @candidacy), status: :unprocessable_entity
    end
  end

  def destroy
    @candidacy.destroy!
    redirect_to candidacies_url, notice: "Candidacy was successfully destroyed.", status: :see_other
  end

  private

  def set_candidacy
    @candidacy = Candidacy.find(params[:id])
  end

  def candidacy_params
    params.require(:candidacy).permit(:person_id, :race_id, :status, :announcement_date, :party_affiliation, :platform_summary)
  end
end