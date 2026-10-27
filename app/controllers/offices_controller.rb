class OfficesController < ApplicationController
  before_action :set_office, only: %i[ show edit update destroy ]

  def index
    offices_scope = Office.preload(:position, jurisdiction: :jurisdictionable, races: [ :election, :candidacies ])
      .joins(:position).order("positions.title", :id)
    offices_scope = offices_scope.matching(filters["q"]) if filters["q"].present?
    offices_scope = offices_scope.in_state(State.includes(:jurisdiction).find(filters["state_id"])) if filters["state_id"].present?
    offices_scope = offices_scope.where(is_active: true) if filters["active"] == "1"
    @pagy, @offices = pagy(offices_scope)
    render Views::Offices::IndexView.new(offices: @offices, pagy: @pagy, filters: filters, states: State.order(:name))
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

  def filters
    @filters ||= params.permit(:q, :state_id, :active).to_h
  end

  def set_office
    @office = Office.includes(:position, :governing_body, :chamber, jurisdiction: :jurisdictionable).find(params[:id])
  end

  def office_params
    params.require(:office).permit(:position_id, :jurisdiction_id, :governing_body_id, :chamber_id, :is_active, :notes)
  end
end
