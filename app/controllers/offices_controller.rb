class OfficesController < ApplicationController
  before_action :set_office, only: %i[ show edit update destroy ]

  def index
    @pagy, @offices = pagy(Office.with_elections_and_candidates.includes(jurisdiction: :jurisdictionable))
    render Views::Offices::IndexView.new(offices: @offices, pagy: @pagy)
  end

  def show
    render Views::Offices::ShowView.new(office: @office)
  end

  def new
    @office = Office.new
    render Views::Offices::NewView.new(office: @office)
  end

  def edit
    render Views::Offices::EditView.new(office: @office)
  end

  def create
    @office = Office.new(office_params)

    if @office.save
      redirect_to @office, notice: "Office was successfully created."
    else
      render Views::Offices::NewView.new(office: @office), status: :unprocessable_entity
    end
  end

  def update
    if @office.update(office_params)
      redirect_to @office, notice: "Office was successfully updated.", status: :see_other
    else
      render Views::Offices::EditView.new(office: @office), status: :unprocessable_entity
    end
  end

  def destroy
    @office.destroy!
    redirect_to offices_url, notice: "Office was successfully destroyed.", status: :see_other
  end

  private

  def set_office
    @office = Office.with_elections_and_candidates.find(params[:id])
  end

  def office_params
    params.require(:office).permit(:position_id, :jurisdiction_id, :governing_body_id, :chamber_id, :is_active, :notes)
  end
end