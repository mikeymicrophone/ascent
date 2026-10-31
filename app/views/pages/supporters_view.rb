# frozen_string_literal: true

class Views::Pages::SupportersView < Views::ApplicationView
  def initialize(page:, active_races:, metrics:)
    @page = page
    @active_races = active_races
    @metrics = metrics
  end

  def view_template
    div(class: "story-page supporters-page") do
      render_intro
      render_funding_case
      render_values_case
      render_support_targets
      render_election_preview
    end
  end

  private

  def render_intro
    hero = @page.fetch(:hero)
    section(class: "story-hero story-hero-supporters") do
      p(class: "story-kicker") { hero.fetch(:kicker) }
      h1(class: "story-title") { hero.fetch(:title) }
      p(class: "story-lead") { hero.fetch(:lead).squish }
      render_actions(hero.fetch(:actions))
    end
  end

  def render_funding_case
    funding = @page.fetch(:funding)
    section(class: "story-section") do
      render_heading(funding)
      div(class: "story-card-grid") do
        funding.fetch(:items).each { render_case_card(it) }
      end
    end
  end

  def render_values_case
    values = @page.fetch(:values)
    section(class: "story-band") do
      render_heading(values)
      div(class: "story-card-grid story-card-grid-compact") do
        values.fetch(:items).each { render_case_card(it) }
      end
    end
  end

  def render_support_targets
    targets = @page.fetch(:support_targets)
    section(class: "story-section") do
      render_heading(targets)
      div(class: "story-support-grid") do
        targets.fetch(:items).each { render_support_target(it) }
      end
    end
  end

  def render_election_preview
    footprint = @page.fetch(:footprint)
    section(class: "story-section") do
      article(class: "story-callout") do
        h2(class: "story-callout-title") { footprint.fetch(:title) }
        p(class: "story-callout-copy") { footprint.fetch(:copy).squish % @metrics }

        if @active_races.any?
          div(class: "story-election-grid") do
            @active_races.each do |race|
              article(class: "story-election-card story-election-card-inline") do
                p(class: "story-election-context") { race_context(race) }
                h3(class: "story-election-title") { race.election.name }
                div(class: "story-card-actions") do
                  link_to footprint.fetch(:mountain_link), mountain_path(race), class: "btn-primary"
                end
              end
            end
          end
        else
          empty = footprint.fetch(:empty)
          div(class: "story-card-actions") do
            link_to empty.fetch(:elections_link), elections_path, class: "btn-secondary"
            link_to empty.fetch(:jurisdictions_link), countries_path, class: "btn-tertiary"
          end
        end
      end
    end
  end

  def render_heading(section)
    div(class: "story-section-heading") do
      p(class: "story-section-kicker") { section.fetch(:kicker) }
      h2(class: "story-section-title") { section.fetch(:title) }
    end
  end

  def render_case_card(item)
    article(class: "story-card") do
      h3(class: "story-card-title") { item.fetch(:title) }
      p(class: "story-card-copy") { item.fetch(:copy).squish }
    end
  end

  def render_support_target(item)
    article(class: "story-support-card") do
      h3(class: "story-card-title") { item.fetch(:title) }
      p(class: "story-card-copy") { item.fetch(:copy).squish }
    end
  end

  def render_actions(actions)
    div(class: "story-actions") do
      actions.each do |action|
        link_to action.fetch(:text), public_send("#{action.fetch(:path)}_path"), class: "btn-#{action.fetch(:style)}"
      end
    end
  end
end
