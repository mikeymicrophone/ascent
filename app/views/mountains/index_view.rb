# frozen_string_literal: true

class Views::Mountains::IndexView < Views::ApplicationView
  def initialize(elections:)
    @elections = elections
  end

  def view_template
    div(class: "mountain-index") do
      h1(class: "page-title") { "Mountain Visualizations" }

      p(class: "page-description") do
        "Select an election to view the approval voting mountain interface, " \
        "or simulate data for testing."
      end

      if @elections.any?
        div(class: "elections-grid") do
          @elections.each do |election|
            render_election_card(election)
          end
        end
      else
        div(class: "mountain-empty-state") do
          h2(class: "subsection-title") { "No active elections are ready for the mountain interface." }
          p(class: "content-text") do
            "Load or create an active election to demonstrate how expressive ratings translate into approval outcomes."
          end
          div(class: "election-actions") do
            link_to "Browse Elections", elections_path, class: "btn-secondary"
            link_to "Project Overview", root_path, class: "btn-tertiary"
          end
        end
      end
    end
  end

  private

  def render_election_card(election)
    div(class: "election-card") do
      h3(class: "election-title") { election.name }
      
      div(class: "election-meta") do
        p { "Candidates: #{election.candidacies.count}" }
        if election.office&.position&.title
          p { "Office: #{election.office.position.title}" }
        end
      end

      div(class: "election-actions") do
        a(href: mountain_path(election), class: "btn-primary") { "View Mountain" }
        button_to("Simulate Data", simulate_mountain_path(election), 
                  method: :post, class: "btn-secondary", form: { style: "display: inline;" })
      end
    end
  end
end
