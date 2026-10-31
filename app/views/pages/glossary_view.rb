# frozen_string_literal: true

class Views::Pages::GlossaryView < Views::ApplicationView
  def initialize(page:)
    @page = page
  end

  def view_template
    div(class: "story-page glossary-page") do
      render_intro
      render_flow_cards
      @page.fetch(:sections).each { render_section(it) }
    end
  end

  private

  def render_intro
    hero = @page.fetch(:hero)
    section(class: "story-hero") do
      p(class: "story-kicker") { hero.fetch(:kicker) }
      h1(class: "story-title") { hero.fetch(:title) }
      p(class: "story-lead") { hero.fetch(:lead).squish }
      render_actions(hero.fetch(:actions))
    end
  end

  def render_flow_cards
    flow = @page.fetch(:flow)
    section(class: "story-band") do
      div(class: "story-section-heading") do
        p(class: "story-section-kicker") { flow.fetch(:kicker) }
        h2(class: "story-section-title") { flow.fetch(:title) }
      end

      div(class: "story-card-grid") do
        flow.fetch(:items).each do |card|
          article(class: "story-card story-card-subtle") do
            p(class: "story-section-kicker") { card.fetch(:title) }
            h3(class: "story-card-title") { card.fetch(:chain) }
            p(class: "story-card-copy") { card.fetch(:copy) }
          end
        end
      end
    end
  end

  def render_section(section_data)
    section(class: "story-section") do
      div(class: "story-section-heading") do
        p(class: "story-section-kicker") { section_data.fetch(:kicker) }
        h2(class: "story-section-title") { section_data.fetch(:title) }
      end

      div(class: "story-card-grid") do
        section_data.fetch(:entries).each { render_entry(it) }
      end
    end
  end

  def render_entry(entry)
    article(class: "story-card") do
      h3(class: "story-card-title") { entry.fetch(:term) }
      p(class: "story-card-copy") { entry.fetch(:definition) }
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
