# frozen_string_literal: true

class Views::Pages::ApprovalVotingView < Views::ApplicationView
  def initialize(page:)
    @page = page
  end

  def view_template
    div(class: "story-page approval-voting-page") do
      render_hero(@page.fetch(:hero))
      @page.fetch(:sections).each { render_section(it) }
    end
  end

  private

  def render_hero(hero)
    section(class: "story-hero") do
      p(class: "story-kicker") { hero.fetch(:kicker) }
      h1(class: "story-title") { hero.fetch(:title) }
      p(class: "story-lead") { hero.fetch(:lead).squish }
      render_actions(hero[:actions])
    end
  end

  def render_section(section)
    case section.fetch(:type)
    when "cards" then render_cards_section(section)
    when "prose" then render_prose_section(section)
    when "callout" then render_callout_section(section)
    else raise ArgumentError, "Unknown section type: #{section[:type]}"
    end
  end

  def render_cards_section(section)
    section(class: section_surface_class(section)) do
      render_heading(section)
      div(class: card_grid_class(section)) do
        section.fetch(:items).each { render_card(it, section) }
      end
    end
  end

  def render_prose_section(section)
    section(class: section_surface_class(section)) do
      render_heading(section)
      div(class: "story-prose") do
        section.fetch(:paragraphs).each do |paragraph|
          p { paragraph.squish }
        end
      end
    end
  end

  def render_callout_section(section)
    section(class: "story-section") do
      article(class: "story-callout") do
        h2(class: "story-callout-title") { section.fetch(:title) }
        p(class: "story-callout-copy") { section.fetch(:copy).squish }
        render_actions(section[:actions], wrapper_class: "story-card-actions")
      end
    end
  end

  def render_heading(section)
    div(class: "story-section-heading") do
      p(class: "story-section-kicker") { section.fetch(:kicker) }
      h2(class: "story-section-title") { section.fetch(:title) }
    end
  end

  def render_card(item, section)
    article(class: card_class(section)) do
      h3(class: "story-card-title") { item.fetch(:title) }
      p(class: "story-card-copy") { item.fetch(:copy).squish }
    end
  end

  def render_actions(actions, wrapper_class: "story-actions")
    return if actions.blank?

    div(class: wrapper_class) do
      actions.each do |action|
        link_to action.fetch(:text), public_send("#{action.fetch(:path)}_path"), class: "btn-#{action.fetch(:style)}"
      end
    end
  end

  def section_surface_class(section)
    section[:surface] == "band" ? "story-band" : "story-section"
  end

  def card_grid_class(section)
    [ "story-card-grid", ("story-card-grid-compact" if section[:layout] == "compact") ].compact.join(" ")
  end

  def card_class(section)
    [ "story-card", ("story-card-subtle" if section[:surface] == "band") ].compact.join(" ")
  end
end
