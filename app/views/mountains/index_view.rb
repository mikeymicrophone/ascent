# frozen_string_literal: true

class Views::Mountains::IndexView < Views::ApplicationView
  def initialize(races:)
    @races = races
  end

  def view_template
    div(class: "mountain-index") do
      h1(class: "page-title") { "Mountain Visualizations" }

      p(class: "page-description") do
        "Select a race to view the approval voting mountain interface, " \
        "or simulate data for testing."
      end

      if @races.any?
        div(class: "mountain-race-grid") do
          @races.each do |race|
            render_race_card(race)
          end
        end
      else
        div(class: "mountain-empty-state") do
          h2(class: "subsection-title") { "No active races are ready for the mountain interface." }
          p(class: "content-text") do
            "Load or create an active race to demonstrate how expressive ratings translate into approval outcomes."
          end
          div(class: "election-actions") do
            link_to "Browse Races", races_path, class: "btn-secondary"
            link_to "Project Overview", root_path, class: "btn-tertiary"
          end
        end
      end
    end
  end

  private

  def render_race_card(race)
    article(class: "mountain-race-card", data: { mode: race.election.mode }) do
      div(class: "mountain-race-card-body") do
        div(class: "mountain-race-card-top") do
          span(class: "mountain-race-mode") do
            case race.election.mode
            when "mock" then "Mock election"
            when "historical" then "Historical replay"
            else "Election"
            end
          end
          span(class: "mountain-race-year") { race.year.year.to_s }
        end

        h2(class: "mountain-race-title") do
          link_to race.office.name, mountain_path(race)
        end
        p(class: "mountain-race-election") { race.election.name }
      end

      div(class: "mountain-race-details") do
        time(datetime: race.election_date.iso8601) do
          icon(:calendar_days)
          plain race.election_date.strftime("%b %-d, %Y")
        end
        span do
          icon(:users_round)
          plain pluralize(race.candidacies.size, "candidate")
        end
      end

      div(class: "mountain-race-actions") do
        link_to mountain_path(race), class: "mountain-race-link" do
          span { "View Mountain" }
          icon(:arrow_up_right)
        end
        if can_simulate_mountains? && race.mock?
          button_to simulate_mountain_path(race), method: :post,
            class: "resource-action resource-action-simulate", form_class: "mountain-race-simulate" do
            Ui::ActionIcon(kind: :simulate)
            span { "Simulate Data" }
          end
        end
      end
    end
  end
end
