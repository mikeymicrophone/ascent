class GovernanceTypesController < ApplicationController
  before_action :set_governance_type, only: %i[ show edit update destroy ]

  def index
    @pagy, @governance_types = pagy(GovernanceType.all)
    render Views::GovernanceTypes::IndexView.new(governance_types: @governance_types, pagy: @pagy, notice: notice)
  end

  def show
    render Views::GovernanceTypes::ShowView.new(governance_type: @governance_type, notice: notice)
  end

  def new
    @governance_type = GovernanceType.new
    render Views::GovernanceTypes::NewView.new(governance_type: @governance_type)
  end

  def edit
    render Views::GovernanceTypes::EditView.new(governance_type: @governance_type)
  end

  def create
    @governance_type = GovernanceType.new(governance_type_params)

    if @governance_type.save
      redirect_to @governance_type, notice: "Governance type was successfully created."
    else
      render Views::GovernanceTypes::NewView.new(governance_type: @governance_type), status: :unprocessable_entity
    end
  end

  def update
    if @governance_type.update(governance_type_params)
      redirect_to @governance_type, notice: "Governance type was successfully updated.", status: :see_other
    else
      render Views::GovernanceTypes::EditView.new(governance_type: @governance_type), status: :unprocessable_entity
    end
  end

  def destroy
    @governance_type.destroy!
    redirect_to governance_types_url, notice: "Governance type was successfully destroyed.", status: :see_other
  end

  private

  def set_governance_type
    @governance_type = GovernanceType.find(params[:id])
  end

  def governance_type_params
    params.require(:governance_type).permit(:name, :description, :authority_level, :decision_making_process)
  end
end