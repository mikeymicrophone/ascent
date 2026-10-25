class DistrictsController < ApplicationController
  before_action :set_district, only: %i[ show edit update destroy ]

  def index
    @pagy, @districts = pagy(District.order(:name))
    render Views::Districts::IndexView.new(districts: @districts, pagy: @pagy)
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

  def set_district
    @district = District.find(params[:id])
  end

  def district_params
    params.require(:district).permit(:name, :kind)
  end
end
