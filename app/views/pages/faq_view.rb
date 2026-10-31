# frozen_string_literal: true

class Views::Pages::FaqView < Views::ApplicationView
  def initialize(page:)
    @page = page
  end

  def view_template
    div(class: "story-page faq-page") do
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
    when "faq" then render_faq_section(section)
    when "prose" then render_prose_section(section)
    when "code" then render_code_section(section)
    when "callout" then render_callout_section(section)
    else raise ArgumentError, "Unknown section type: #{section[:type]}"
    end
  end

  def render_faq_section(section)
    section(class: section_surface_class(section)) do
      render_heading(section)
      div(class: "story-card-grid") do
        section.fetch(:items).each do |item|
          article(class: card_class(section)) do
            h3(class: "story-card-title") { item.fetch(:question) }
            p(class: "story-card-copy") { item.fetch(:answer).squish }
          end
        end
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

  def render_code_section(section)
    section(class: "story-section") do
      article(class: "story-code-block") do
        if section[:filename]
          p(class: "story-code-filename") { section.fetch(:filename) }
        end
        pre(class: "story-code") do
          code(class: "language-#{section.fetch(:language, "text")}") { section.fetch(:body) }
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

  def render_actions(actions, wrapper_class: "story-actions")
    return if actions.blank?

    div(class: wrapper_class) do
      actions.each { render_action(it) }
    end
  end

  def render_action(action)
    css = "btn-#{action.fetch(:style)}"
    if action[:url]
      a(href: action.fetch(:url), class: css, target: "_blank", rel: "noopener noreferrer") { action.fetch(:text) }
    else
      link_to action.fetch(:text), public_send("#{action.fetch(:path)}_path"), class: css
    end
  end

  def section_surface_class(section)
    section[:surface] == "band" ? "story-band" : "story-section"
  end

  def card_class(section)
    [ "story-card", ("story-card-subtle" if section[:surface] == "band") ].compact.join(" ")
  end
end
