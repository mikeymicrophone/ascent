class Views::Partials::CandidacyPartial < Views::ApplicationView
  def initialize(candidacy:)
    @candidacy = candidacy
  end

  def view_template(&)
    div(id: dom_id(@candidacy), class: "candidacy-partial") do
      # Header with candidate name and status
      div(class: "partial-header") do
        h3(class: "partial-title") { @candidacy.person.full_name }
        div(class: "header-indicators") do
          span(class: "status-indicator status-#{@candidacy.status.downcase}") { @candidacy.status }
          if @candidacy.party_affiliation.present?
            span(class: "status-indicator status-party") { @candidacy.party_affiliation }
          end
        end
      end
      
      # Main content with improved layout
      div(class: "partial-content") do
        # Election and timing information
        div(class: "info-grid") do
          div(class: "info-item") do
            span(class: "info-label") { "Election" }
            link_to @candidacy.election.name, @candidacy.election, class: "link election info-value"
          end
          div(class: "info-item") do
            span(class: "info-label") { "Announced" }
            span(class: "info-value") { @candidacy.announcement_date.strftime("%B %d, %Y") }
          end
        end
        
        # Platform summary
        if @candidacy.platform_summary.present?
          div(class: "content-section") do
            div(class: "content-description") { simple_format(@candidacy.platform_summary) }
          end
        end
      end

      # Expandable sections with grid layout
      div(class: "expandable-sections") do
        expandable(@candidacy, :stances, title: "Policy Positions") do |stances|
          div(class: "expandable-grid") do
            stances.each do |stance|
              CandidateStancePartial(stance: stance)
            end
          end
        end

        expandable(@candidacy, :ratings, title: "Voter Ratings") do |ratings|
          div(class: "expandable-grid") do
            ratings.each { RatingPartial(rating: it) }
          end
        end
      end
    end
  end
end