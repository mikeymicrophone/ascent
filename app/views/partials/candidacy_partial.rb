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
          if @candidacy.ballot_summary.present?
            span(class: "status-indicator status-party") { @candidacy.ballot_summary }
          end
        end
      end

      # Main content with improved layout
      div(class: "partial-content") do
        # Election and timing information
        div(class: "info-grid") do
          div(class: "info-item") do
            span(class: "info-label") { "Race" }
            link_to @candidacy.race.name, @candidacy.race, class: "link race info-value"
          end
          div(class: "info-item") do
            span(class: "info-label") { "Election" }
            link_to @candidacy.election.name, @candidacy.election, class: "link election info-value"
          end
          if @candidacy.announcement_date
            div(class: "info-item") do
              span(class: "info-label") { "Announced" }
              span(class: "info-value") { @candidacy.announcement_date.to_fs(:display) }
            end
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
      end

      rating_totals
    end
  end

  private

  # Only totals: a rating is private to its voter, so no one may see who rated the candidate or how.
  def rating_totals
    section(class: "candidacy-ratings") do
      h4(class: "candidacy-ratings-title") { "Ratings" }
      if @candidacy.ratings.any?
        div(class: "stats-grid") do
          Stat(value: @candidacy.ratings.count, label: "voters rated")
          Stat(value: @candidacy.average_rating.to_f, label: "average rating")
          Stat(value: @candidacy.approvals_count, label: "approve")
        end
      else
        p(class: "candidacy-ratings-empty") { "No voter has rated this candidate yet." }
      end
    end
  end
end
