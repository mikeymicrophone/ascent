class RacesController < ApplicationController
  before_action :set_race, only: %i[ show edit update destroy ]

  def index
    races_scope = Race.with_naming_details.includes(candidacies: :person).recent
    races_scope = races_scope.where(office_id: params[:office_id]) if params[:office_id]
    races_scope = races_scope.where(election_id: params[:election_id]) if params[:election_id]
    @pagy, @races = pagy(races_scope)
    render Views::Races::IndexView.new(races: @races, pagy: @pagy)
  end

  def show
    render Views::Races::ShowView.new(race: @race)
  end

  def new
    @race = Race.new(election_id: params[:election_id])
    render Views::Races::NewView.new(race: @race)
  end

  def edit
    render Views::Races::EditView.new(race: @race)
  end

  def create
    @race = Race.new(race_params)

    if @race.save
      redirect_to @race, notice: "Race was successfully created."
    else
      render Views::Races::NewView.new(race: @race), status: :unprocessable_entity
    end
  end

  def update
    if @race.update(race_params)
      redirect_to @race, notice: "Race was successfully updated.", status: :see_other
    else
      render Views::Races::EditView.new(race: @race), status: :unprocessable_entity
    end
  end

  def destroy
    @race.destroy!
    redirect_to races_url, notice: "Race was successfully destroyed.", status: :see_other
  end

  private

  def set_race
    @race = Race.with_naming_details.find(params[:id])
  end

  def race_params
    params.require(:race).permit(:election_id, :office_id, :status, :description)
  end
end
