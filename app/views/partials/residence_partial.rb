# frozen_string_literal: true

# A residence's page body: who lives where, since when, and its standing.
class Views::Partials::ResidencePartial < Views::ApplicationView
  prop :residence, Residence

  def view_template
    section(class: "place-section") do
      section_heading("The residence")
      dl(class: "place-facts-list") do
        FactRow(label: "Voter") { link_to @residence.voter.full_name, @residence.voter, class: "text-link" }
        FactRow(label: "Lives in") { jurisdiction_link @residence.jurisdiction }
        FactRow(label: "Registered") { @residence.registered_at.strftime("%b %-d, %Y") } if @residence.registered_at
        FactRow(label: "Status") { @residence.status.humanize }
      end
      p(class: "card-text") { @residence.notes } if @residence.notes.present?
    end
  end
end
