# frozen_string_literal: true

class Views::Pages::HomeView < Views::ApplicationView
  def initialize(active_elections:, metrics:)
    @active_elections = active_elections
    @metrics = metrics
  end

  def view_template
    div(class: "story-page home-page") do
      render_hero
      render_metrics
      render_pillars
      render_trust_section
      render_active_elections
    end
  end

  private

  def render_hero
    section(class: "story-hero") do
      p(class: "story-kicker") { "Civic simulation for approval voting and policy clarity" }
      h1(class: "story-title") { "Ascent helps communities test richer ways to vote before changing the real world." }
      p(class: "story-lead") do
        "The project models elections, expressive ratings, and issue positions in one place so researchers, organizers, and donors can study how voter choice, candidate coalitions, and policy responsibility actually interact."
      end

      div(class: "story-actions") do
        link_to "Explore the Mountain Demo", mountains_path, class: "btn-primary"
        link_to "For Philanthropic Partners", supporters_path, class: "btn-tertiary"
      end
    end
  end

  def render_metrics
    section(class: "story-section") do
      div(class: "story-metric-grid") do
        @metrics.each do |metric_key, value|
          article(class: "story-metric-card") do
            p(class: "story-metric-value") { value.to_s }
            p(class: "story-metric-label") { metric_label(metric_key) }
          end
        end
      end
    end
  end

  def render_pillars
    section(class: "story-section") do
      div(class: "story-section-heading") do
        p(class: "story-section-kicker") { "What the platform is for" }
        h2(class: "story-section-title") { "Three ways Ascent turns election reform into something testable." }
      end

      div(class: "story-card-grid") do
        render_pillar(
          "Expressive ballots",
          "Approval-style ratings let voters signal more than one acceptable outcome, which makes spoiler-risk and coalition behavior easier to observe."
        )
        render_pillar(
          "Preference simulation",
          "Mountain views translate raw ratings into a visible distribution so people can inspect whether consensus candidates exist and where polarization lives."
        )
        render_pillar(
          "Policy responsibility",
          "Issues, approaches, offices, and jurisdictions sit in the same model so the public can ask whether a given office can actually act on a promise."
        )
      end
    end
  end

  def render_trust_section
    section(class: "story-band") do
      div(class: "story-section-heading") do
        p(class: "story-section-kicker") { "Designed for cross-partisan scrutiny" }
        h2(class: "story-section-title") { "The framing stays civic and practical, not partisan." }
      end

      div(class: "story-card-grid story-card-grid-compact") do
        render_trust_card("Voter agency", "People can express layered preferences instead of being forced into a single strategic choice.")
        render_trust_card("Institutional fit", "The system links policy claims back to real offices and jurisdictions, which helps keep promises legible.")
        render_trust_card("Transparent experimentation", "Mock elections and simulation data let communities explore reforms without pretending theory is enough.")
        render_trust_card("Local usefulness", "The data model is structured around places, offices, and residents, which keeps the project grounded in administration.")
      end
    end
  end

  def render_active_elections
    section(class: "story-section") do
      div(class: "story-section-heading") do
        p(class: "story-section-kicker") { "Current workspace" }
        h2(class: "story-section-title") { "Active election spaces ready for exploration." }
      end

      if @active_elections.any?
        div(class: "story-election-grid") do
          @active_elections.each do |election|
            article(class: "story-election-card") do
              p(class: "story-election-context") { election_context(election) }
              h3(class: "story-election-title") { election.name }
              p(class: "story-election-summary") { election.description }
              div(class: "story-card-actions") do
                link_to "Open Mountain", mountain_path(election), class: "btn-primary"
                link_to "See Election Data", election_path(election), class: "btn-secondary"
              end
            end
          end
        end
      else
        article(class: "story-callout") do
          h3(class: "story-callout-title") { "No active elections are loaded yet." }
          p(class: "story-callout-copy") do
            "The supporting data model is already in place, so the next step is to seed or model a live example and use the mountain interface to walk people through it."
          end
          div(class: "story-card-actions") do
            link_to "Browse Election Data", elections_path, class: "btn-secondary"
            link_to "Review Jurisdictions", countries_path, class: "btn-tertiary"
          end
        end
      end
    end
  end

  def render_pillar(title, copy)
    article(class: "story-card") do
      h3(class: "story-card-title") { title }
      p(class: "story-card-copy") { copy }
    end
  end

  def render_trust_card(title, copy)
    article(class: "story-card story-card-subtle") do
      h3(class: "story-card-title") { title }
      p(class: "story-card-copy") { copy }
    end
  end
end
