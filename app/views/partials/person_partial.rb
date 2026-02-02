class Views::Partials::PersonPartial < Views::ApplicationView
  def initialize(person:)
    @person = person
  end

  def view_template(&)
    div(id: dom_id(@person), class: "person-partial") do
      h3 { @person.first_name + " " + @person.last_name }
      div do
        span { @person.email }
      end
      div do
        div(class: "mt-1") { simple_format(@person.bio) }
      end

      expandable(@person, :candidacies, title: "Elections") do |candidacies|
        candidacies_preview(@person)
      end
    end
  end

  def candidacies_preview(person = @person)
    div(class: "candidacies-preview") do
      person_with_candidacies = Person.with_recent_candidacies.find(person.id)
      candidacies_to_show = person_with_candidacies.candidacies.limit(5)

      candidacies_to_show.each do |candidacy|
        div(class: "candidacy-preview-item") do
          candidacy_item(candidacy)
        end
      end

      if person.candidacies.count > 5
        div(class: "candidacies-view-all") do
          link_to "View all #{person.candidacies.count} elections",
                  candidacies_path(person_id: person.id),
                  class: "link view-all"
        end
      end
    end
  end

  def candidacy_item(candidacy)
    election = candidacy.election
    office = election.office

    div(class: "candidacy-header") do
      link_to election.name, election, class: "link election"
      span(class: "candidacy-office") { " for #{office.position.title}" }
    end

    div(class: "candidacy-details") do
      span(class: "election-date") { election.election_date.strftime("%B %d, %Y") }
      span(class: "status-indicator status-#{candidacy.status}") { candidacy.status.capitalize }

      if candidacy.party_affiliation.present?
        span(class: "candidacy-party") { " (#{candidacy.party_affiliation})" }
      end
    end
  end
end
