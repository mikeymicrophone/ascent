# frozen_string_literal: true

# A year's page body: what kind of election year it is, and its elections.
class Views::Partials::YearPartial < Views::ApplicationView
  ELECTION_LIMIT = 12

  prop :year, Year

  def view_template
    section(class: "place-section") do
      section_heading("About #{@year.year}")
      p(class: "card-text") { @year.description } if @year.description.present?
      dl(class: "place-facts-list") do
        FactRow(label: "Even year") { @year.is_even_year ? "Yes" : "No" }
        FactRow(label: "Presidential year") { @year.is_presidential_year ? "Yes" : "No" }
      end
    end
    elections = @year.elections.order(:election_date, :name)
    RelatedList(heading: "Elections", records: elections.limit(ELECTION_LIMIT).to_a, total: elections.count, see_all: elections_path(tab: "all"),
      noun: "elections") do |election|
      ListRow(record: election, title: election.name, meta: election.election_date.strftime("%b %-d, %Y")) { StatusChip(status: election.status) }
    end
  end
end
