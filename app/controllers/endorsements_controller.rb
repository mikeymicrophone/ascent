class EndorsementsController < ApplicationController
  def index
    endorsements = Endorsement.includes(:endorser, candidacy: [ :person, { race: [ :election, { office: [ :position, { jurisdiction: :jurisdictionable } ] } ] } ])
      .order(endorsed_on: :desc, id: :desc)
    endorsements = endorsements.matching(filters["q"]) if filters["q"].present?
    endorsements = endorsements.where(kind: filters["kind"]) if filters["kind"].present?
    endorsements = endorsements.current if filters["status"] == "current"
    endorsements = endorsements.where.not(withdrawn_on: nil) if filters["status"] == "withdrawn"
    organization = Organization.find(filters["organization_id"]) if filters["organization_id"].present?
    endorsements = endorsements.where(endorser: organization) if organization
    pagy, records = pagy(endorsements)
    render Views::Endorsements::IndexView.new(endorsements: records, pagy: pagy, filters: filters, organization: organization)
  end

  def show
    endorsement = Endorsement.includes(:endorser, candidacy: [ :person, { race: [ :election, { office: [ :position, { jurisdiction: :jurisdictionable } ] } ] } ]).find(params[:id])
    render Views::Endorsements::ShowView.new(endorsement: endorsement)
  end

  private

  def filters
    @filters ||= params.permit(:q, :kind, :status, :organization_id).to_h
  end
end
