class CountiesController < ApplicationController
  before_action :set_county, only: %i[ show edit update destroy ]

  def index
    counties_scope = County.includes(:state).order(:name, :id)
    counties_scope = counties_scope.named_like(filters["q"]) if filters["q"].present?
    counties_scope = counties_scope.where(state_id: filters["state_id"]) if filters["state_id"].present?
    @pagy, @counties = pagy(counties_scope)
    render Views::Counties::IndexView.new(counties: @counties, pagy: @pagy, filters: filters, states: State.order(:name),
      town_counts: Municipality.where(county: @counties).group(:county_id).count)
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

  def filters
    @filters ||= params.permit(:q, :state_id).to_h
  end

  def set_county
    @county = County.find(params[:id])
  end

  def county_params
    params.require(:county).permit(:name, :code, :state_id)
  end
end
