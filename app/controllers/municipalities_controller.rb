class MunicipalitiesController < ApplicationController
  before_action :set_municipality, only: %i[ show edit update destroy ]

  def index
    municipalities_scope = Municipality.includes(:county, state: :country).order(:name, :id)
    municipalities_scope = municipalities_scope.named_like(filters["q"]) if filters["q"].present?
    municipalities_scope = municipalities_scope.in_state(State.find(filters["state_id"])) if filters["state_id"].present?
    municipalities_scope = municipalities_scope.where(county_id: filters["county_id"]) if filters["county_id"].present?
    @pagy, @municipalities = pagy(municipalities_scope)
    render Views::Municipalities::IndexView.new(municipalities: @municipalities, pagy: @pagy, filters: filters, states: State.order(:name),
      county: (County.includes(:state).find(filters["county_id"]) if filters["county_id"].present?))
  end

  def show
    render Views::Municipalities::ShowView.new(municipality: @municipality)
  end

  def new
    @municipality = Municipality.new
    render Views::Municipalities::NewView.new(municipality: @municipality)
  end

  def edit
    render Views::Municipalities::EditView.new(municipality: @municipality)
  end

  def create
    @municipality = Municipality.new(municipality_params)
    @municipality.build_jurisdiction(parent: (@municipality.county || @municipality.state)&.jurisdiction)

    if @municipality.save
      redirect_to @municipality, notice: "Municipality was successfully created."
    else
      render Views::Municipalities::NewView.new(municipality: @municipality), status: :unprocessable_entity
    end
  end

  def update
    if @municipality.update(municipality_params)
      redirect_to @municipality, notice: "Municipality was successfully updated.", status: :see_other
    else
      render Views::Municipalities::EditView.new(municipality: @municipality), status: :unprocessable_entity
    end
  end

  def destroy
    @municipality.destroy!
    redirect_to municipalities_url, notice: "Municipality was successfully destroyed.", status: :see_other
  end

  private

  def filters
    @filters ||= params.permit(:q, :state_id, :county_id).to_h
  end

  def set_municipality
    @municipality = Municipality.find(params[:id])
  end

  def municipality_params
    params.require(:municipality).permit(:name, :state_id, :county_id)
  end
end
