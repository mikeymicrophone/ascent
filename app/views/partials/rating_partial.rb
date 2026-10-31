# frozen_string_literal: true

# A rating's page body, seen only by its voter or an admin.
class Views::Partials::RatingPartial < Views::ApplicationView
  prop :rating, Rating

  def view_template
    section(class: "place-section") do
      section_heading("The rating")
      dl(class: "place-facts-list") do
        FactRow(label: "Voter") { link_to @rating.voter.full_name, @rating.voter, class: "text-link" }
        FactRow(label: "Candidate") { link_to @rating.candidacy.name, @rating.candidacy, class: "text-link" }
        FactRow(label: "Race") { link_to @rating.candidacy.race.office.name, @rating.candidacy.race, class: "text-link" }
        FactRow(label: "Rating", value_class: "glance-value") { @rating.rating.to_s }
      end
    end
  end
end
