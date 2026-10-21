class CountiesController < ApplicationController
  before_action :set_county, only: %i[ show edit update destroy ]

  def index
    @pagy, @counties = pagy(County.includes(:state).order(:name))
    render Views::Counties::IndexView.new(counties: @counties, pagy: @pagy)
  end

  def show
    render Views::Counties::ShowView.new(county: @county)
  end

  def new
    @county = County.new
    render Views::Counties::NewView.new(county: @county)
  end

  def edit
    render Views::Counties::EditView.new(county: @county)
  end

  def create
    @county = County.new(county_params)
    @county.build_jurisdiction(parent: @county.state&.jurisdiction)

    if @county.save
      redirect_to @county, notice: "County was successfully created."
    else
      render Views::Counties::NewView.new(county: @county), status: :unprocessable_entity
    end
  end

  def update
    if @county.update(county_params)
      redirect_to @county, notice: "County was successfully updated.", status: :see_other
    else
      render Views::Counties::EditView.new(county: @county), status: :unprocessable_entity
    end
  end

  def destroy
    @county.destroy!
    redirect_to counties_url, notice: "County was successfully destroyed.", status: :see_other
  end

  private

  def set_county
    @county = County.find(params[:id])
  end

  def county_params
    params.require(:county).permit(:name, :code, :state_id)
  end
end