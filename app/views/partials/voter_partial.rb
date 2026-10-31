# frozen_string_literal: true

class Views::Partials::VoterPartial < Views::ApplicationView
  RACE_LIMIT = 10

  prop :voter, Voter

  def view_template
    section(class: "place-section") do
      section_heading("Account")
      dl(class: "place-facts-list") do
        FactRow(label: "Born") { @voter.birth_date.strftime("%b %-d, %Y") } if @voter.birth_date
        FactRow(label: "Verified") { @voter.is_verified ? "Yes" : "No" }
        FactRow(label: "Joined") { @voter.created_at.strftime("%b %-d, %Y") }
        if current_voter&.can_moderate? && current_voter != @voter
          FactRow(label: "Role") { @voter.role&.capitalize || "Voter" }
          FactRow(label: "Profile visibility") { @voter.profile_hidden? ? "Hidden" : "Visible" }
        end
      end
      if current_voter&.can_moderate? && current_voter != @voter
        div(class: "place-actions") do
          button_to(@voter.profile_hidden? ? "Unhide profile" : "Hide profile",
            hide_profile_voter_path(@voter),
            method: :patch,
            params: { voter: { profile_hidden: !@voter.profile_hidden? } },
            class: "secondary")
        end
      end
    end
    if allowed_to?(:view_voting_activity?, @voter, context: { voter: current_voter })
      RelatedList(heading: "Races taken part in", records: races.first(RACE_LIMIT), total: races.size) { |race| race_row(race) }
    end
  end

  private

  def ratings_by_race
    @ratings_by_race ||= @voter.ratings.includes(:candidacy).group_by { it.candidacy.race_id }
  end

  def baselines_by_race
    @baselines_by_race ||= @voter.voter_race_baselines.index_by(&:race_id)
  end

  # Latest election first.
  def races
    @races ||= Race.where(id: ratings_by_race.keys | baselines_by_race.keys).includes(:election, office: :position)
      .sort_by { -it.election.election_date.jd }
  end

  def race_row(race)
    rated = ratings_by_race.fetch(race.id, []).size
    baseline = baselines_by_race[race.id]
    ListRow(record: race, title: race.office.name,
      meta: [ race.election.name, pluralize(rated, "rating"), (baseline && "baseline #{baseline.baseline}") ].compact.join(" · ")) do
      StatusChip(status: race.status)
    end
  end
end
