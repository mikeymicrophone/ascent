class OrganizationsController < ApplicationController
  def index
    organizations = directory_model.includes(:state).order(:name, :state_id, :id)
    organizations = organizations.named_like(filters["q"]) if filters["q"].present?
    organizations = organizations.where(state_id: filters["state_id"]) if filters["state_id"].present?
    if filters["kind"].present?
      organizations = filters["kind"] == "party" ? organizations.where(type: "Party") : organizations.where(kind: filters["kind"])
    end
    pagy, records = pagy(organizations)
    render Views::Organizations::IndexView.new(organizations: records, pagy: pagy, filters: filters,
      states: State.order(:name), parties: directory_model == Party)
  end

  def show
    render Views::Organizations::ShowView.new(organization: directory_model.includes(:state).find(params[:id]))
  end

  private

  def directory_model
    Organization
  end

  def filters
    @filters ||= params.permit(:q, :state_id, :kind).to_h
  end
end
