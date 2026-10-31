# frozen_string_literal: true

# An area of concern's page body: its domain and scope, and the laws within it.
class Views::Partials::AreaOfConcernPartial < Views::ApplicationView
  prop :area_of_concern, AreaOfConcern

  def view_template
    section(class: "place-section") do
      section_heading("About this area")
      p(class: "card-text") { @area_of_concern.description } if @area_of_concern.description.present?
      dl(class: "place-facts-list") do
        FactRow(label: "Domain") { @area_of_concern.policy_domain } if @area_of_concern.policy_domain.present?
        FactRow(label: "Scope") { @area_of_concern.regulatory_scope } if @area_of_concern.regulatory_scope.present?
      end
    end
    policies = @area_of_concern.policies.includes(:governing_body).order(:title).to_a
    RelatedList(heading: "Laws in this area", records: policies, total: policies.size) do |policy|
      ListRow(record: policy, title: policy.title, meta: policy.governing_body&.name) { StatusChip(status: policy.status) }
    end
  end
end
