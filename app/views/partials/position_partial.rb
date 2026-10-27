# frozen_string_literal: true

# A position's page body: its branch and term, and the offices that hold it.
class Views::Partials::PositionPartial < Views::ApplicationView
  OFFICE_LIMIT = 12

  prop :position, Position

  def view_template
    section(class: "place-section") do
      section_heading("About the position")
      p(class: "card-text") { @position.description } if @position.description.present?
      dl(class: "place-facts-list") do
        FactRow(label: "Branch") { @position.branch.humanize } if @position.branch
        FactRow(label: "Term") { pluralize(@position.term_length_years, "year") } if @position.term_length_years
      end
    end
    offices = @position.offices.includes(jurisdiction: :jurisdictionable)
    RelatedList(heading: "Offices", records: offices.limit(OFFICE_LIMIT).to_a, total: offices.count, see_all: offices_path(q: @position.title),
      noun: "offices") { |office| ListRow(record: office, title: office.name, meta: office.seat_label) }
  end
end
