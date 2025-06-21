class Views::People::PersonPartial < Views::ApplicationView
  def initialize(person:)
    @person = person
  end

  def view_template(&)
    div(id: dom_id(@person), class: "person-partial") do
      h3 { @person.first_name }
      div do
        span { "Last name:" }
        whitespace
        span { @person.last_name }
      end
      div do
        span { "Middle name:" }
        whitespace
        span { @person.middle_name }
      end
      div do
        span { "Email:" }
        whitespace
        span { @person.email }
      end
      div do
        span { "Birth date:" }
        whitespace
        span { @person.birth_date }
      end
      div do
        span { "Bio:" }
        whitespace
        div(class: "mt-1") { simple_format(@person.bio) }
      end
      
      # Candidacy History expandable section
      if @person.candidacies.any?
        expandable_candidacies
      end
    end
  end

  def expandable_candidacies(person = @person)
    Views::Components::ExpandableSection(
      title: "Elections",
      count: person.candidacies.count
    ) do
      candidacies_preview(person)
    end
  end

  def candidacies_preview(person = @person)
    div(class: "candidacies-preview") do
      # Use the with_recent_candidacies scope which already includes the ordering
      person_with_candidacies = Person.with_recent_candidacies.find(person.id)
      candidacies_to_show = person_with_candidacies.candidacies.limit(5)
      
      candidacies_to_show.each do |candidacy|
        div(class: "candidacy-preview-item") do
          candidacy_item(candidacy)
        end
      end
      
      # Show "View All" link if there are more than 5 candidacies
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
      # Election date
      span(class: "election-date") { election.election_date.strftime("%B %d, %Y") }
      
      # Status indicator  
      span(class: "status-indicator status-#{candidacy.status}") { candidacy.status.capitalize }
      
      # Party affiliation if present
      if candidacy.party_affiliation.present?
        span(class: "candidacy-party") { " (#{candidacy.party_affiliation})" }
      end
    end
  end
end