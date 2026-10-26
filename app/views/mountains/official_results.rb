# frozen_string_literal: true

# A historical race's certified result, shown once the voter has saved their own replay.
class Views::Mountains::OfficialResults < Views::ApplicationView
  prop :race, Race

  def view_template
    section(class: "side-card official-results") do
      h2(class: "card-heading") { "The real result" }
      p(class: "official-method") { "Decided by #{@race.decided_by.to_s.humanize(capitalize: false).presence || "the official count"}" }
      ol(class: "official-list") do
        @race.official_results.by_votes.includes(candidacy: :person).each do |result|
          li(class: "official-item#{" is-winner" if result.winner}") do
            span(class: "official-name") { result.candidacy.person.full_name }
            span(class: "official-share") { result.vote_share ? "#{result.vote_share.round(1)}%" : ActiveSupport::NumberHelper.number_to_delimited(result.votes) }
          end
        end
      end
    end
  end
end
