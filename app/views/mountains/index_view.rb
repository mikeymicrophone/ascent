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
        div(class: "elections-grid") do
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
    div(class: "election-card") do
      h3(class: "election-title") { race.name }
      
      div(class: "election-meta") do
        p { "Election: #{race.election.name}" }
        p { "Office: #{race.office.position.title}" }
        p { "Candidates: #{race.candidacies.size}" }
      end

      div(class: "election-actions") do
        a(href: mountain_path(race), class: "btn-primary") { "View Mountain" }
        button_to("Simulate Data", simulate_mountain_path(race), 
                  method: :post, class: "btn-secondary", form: { style: "display: inline;" })
      end
    end
  end
end
