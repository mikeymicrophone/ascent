# frozen_string_literal: true

# A governance type's page body: how bodies of its kind decide, and the bodies of its kind.
class Views::Partials::GovernanceTypePartial < Views::ApplicationView
  BODY_LIMIT = 5

  prop :governance_type, GovernanceType

  def view_template
    section(class: "place-section") do
      section_heading("How it works")
      p(class: "card-text") { @governance_type.description } if @governance_type.description.present?
      dl(class: "place-facts-list") do
        FactRow(label: "Decides by") { @governance_type.decision_making_process } if @governance_type.decision_making_process.present?
      end
    end
    bodies = @governance_type.governing_bodies.includes(:jurisdiction).order(:name)
    RelatedList(heading: "Governing bodies", records: bodies.limit(BODY_LIMIT).to_a, total: bodies.count,
      see_all: governance_type_governing_bodies_path(@governance_type), noun: "governing bodies") do |body|
      ListRow(record: body, title: body.name, meta: body.jurisdiction&.name)
    end
  end
end
