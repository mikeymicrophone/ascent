class Views::Candidacies::CandidacyPartial < Views::ApplicationView
  def initialize(candidacy:)
    @candidacy = candidacy
  end

  def view_template(&)
    div(id: dom_id(@candidacy), class: "candidacy-partial") do
      h3 { @candidacy.person.full_name }
      div do
        span { "Election:" }
        whitespace
        link_to @candidacy.election.name, @candidacy.election, class: "link election"
      end
      div do
        span { "Status:" }
        whitespace
        span { @candidacy.status }
      end
      div do
        span { "Announcement date:" }
        whitespace
        span { @candidacy.announcement_date.strftime("%B %d, %Y") }
      end
      div do
        span { "Party affiliation:" }
        whitespace
        span { @candidacy.party_affiliation }
      end
      div do
        span { "Platform summary:" }
        whitespace
        div(class: "mt-1") { simple_format(@candidacy.platform_summary) }
      end

      expandable(@candidacy, :stances, title: "Policy Positions") do |stances|
        stances.each do |stance|
          CandidateStancePartial(stance: stance)
        end
      end
    end
  end
end