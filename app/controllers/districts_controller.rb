class DistrictsController < ApplicationController
  before_action :set_district, only: %i[ show edit update destroy ]

  def index
    districts_scope = District.includes(jurisdiction: { parent: :jurisdictionable }).in_natural_order
    districts_scope = districts_scope.named_like(filters["q"]) if filters["q"].present?
    districts_scope = districts_scope.in_state(State.includes(:jurisdiction).find(filters["state_id"])) if filters["state_id"].present?
    districts_scope = districts_scope.where(kind: filters["kind"]) if filters["kind"].present?
    @pagy, @districts = pagy(districts_scope)
    render Views::Districts::IndexView.new(districts: @districts, pagy: @pagy, filters: filters, states: State.order(:name),
      kinds: District.distinct.order(:kind).pluck(:kind))
  end

  def show
    render Views::Districts::ShowView.new(district: @district)
  end

  def new
    @district = District.new
    render Views::Districts::NewView.new(district: @district)
  end

  def edit
    render Views::Districts::EditView.new(district: @district)
  end

  def create
    @district = District.new(district_params)
    @district.build_jurisdiction

    if @district.save
      redirect_to @district, notice: "District was successfully created."
    else
      render Views::Districts::NewView.new(district: @district), status: :unprocessable_entity
    end
  end

  def update
    if @district.update(district_params)
      redirect_to @district, notice: "District was successfully updated.", status: :see_other
    else
      render Views::Districts::EditView.new(district: @district), status: :unprocessable_entity
    end
  end

  def destroy
    @district.destroy!
    redirect_to districts_url, notice: "District was successfully destroyed.", status: :see_other
  end

  private

  def filters
    @filters ||= params.permit(:q, :state_id, :kind).to_h
  end

  def set_district
    @district = District.find(params[:id])
  end

  def district_params
    params.require(:district).permit(:name, :kind)
  end
end
