class GoverningBodiesController < ApplicationController
  before_action :set_governing_body, only: %i[ show edit update destroy ]

  def index
    bodies = GoverningBody.includes(:governance_type, jurisdiction: :jurisdictionable).by_governance_type(params[:governance_type_id] || filters["governance_type_id"])
      .order(:name)
    bodies = bodies.named_like(filters["q"]) if filters["q"].present?
    @pagy, @governing_bodies = pagy(bodies)
    render Views::GoverningBodies::IndexView.new(governing_bodies: @governing_bodies, pagy: @pagy, parent: filtering_governance_type,
      filters: filters, governance_types: GovernanceType.order(:name), policy_counts: Policy.where(governing_body: @governing_bodies).group(:governing_body_id).count)
  end

  def show
    render Views::GoverningBodies::ShowView.new(governing_body: @governing_body)
  end

  def new
    @governing_body = GoverningBody.new
    render Views::GoverningBodies::NewView.new(governing_body: @governing_body)
  end

  def edit
    render Views::GoverningBodies::EditView.new(governing_body: @governing_body)
  end

  def create
    @governing_body = GoverningBody.new(governing_body_params)

    if @governing_body.save
      redirect_to @governing_body, notice: "Governing body was successfully created."
    else
      render Views::GoverningBodies::NewView.new(governing_body: @governing_body), status: :unprocessable_entity
    end
  end

  def update
    if @governing_body.update(governing_body_params)
      redirect_to @governing_body, notice: "Governing body was successfully updated.", status: :see_other
    else
      render Views::GoverningBodies::EditView.new(governing_body: @governing_body), status: :unprocessable_entity
    end
  end

  def destroy
    @governing_body.destroy!
    redirect_to governing_bodies_url, notice: "Governing body was successfully destroyed.", status: :see_other
  end

  private

  def filters
    @filters ||= params.permit(:q, :governance_type_id).to_h
  end


  def filtering_governance_type
    GovernanceType.find(params[:governance_type_id]) if params[:governance_type_id]
  end

  def set_governing_body
    @governing_body = GoverningBody.find(params[:id])
  end

  def governing_body_params
    params.require(:governing_body).permit(:name, :jurisdiction_id, :governance_type_id, :branch, :description, :meeting_schedule, :is_active, :established_date)
  end
end
