class CitiesController < ApplicationController
  before_action :set_city, only: %i[ show edit update destroy ]

  def index
    cities_scope = City.with_office_data
    
    # Filter by state if provided
    if params[:state_id].present?
      @state = State.find(params[:state_id])
      cities_scope = cities_scope.in_state(@state)
    end
    
    @pagy, @cities = pagy(cities_scope)
    render Views::Cities::IndexView.new(
      cities: @cities, 
      pagy: @pagy, 
      notice: notice,
      filtered_state: @state
    )
  end

  def show
    render Views::Cities::ShowView.new(city: @city, notice: notice)
  end

  def new
    @city = City.new
    render Views::Cities::NewView.new(city: @city)
  end

  def edit
    render Views::Cities::EditView.new(city: @city)
  end

  def create
    @city = City.new(city_params)

    if @city.save
      redirect_to @city, notice: "City was successfully created."
    else
      render Views::Cities::NewView.new(city: @city), status: :unprocessable_entity
    end
  end

  def update
    if @city.update(city_params)
      redirect_to @city, notice: "City was successfully updated.", status: :see_other
    else
      render Views::Cities::EditView.new(city: @city), status: :unprocessable_entity
    end
  end

  def destroy
    @city.destroy!
    redirect_to cities_url, notice: "City was successfully destroyed.", status: :see_other
  end

  private

  def set_city
    @city = City.find(params[:id])
  end

  def city_params
    params.require(:city).permit(:name, :state_id)
  end
end