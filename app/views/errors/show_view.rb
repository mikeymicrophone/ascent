# frozen_string_literal: true

class Views::Errors::ShowView < Views::ApplicationView
  def initialize(page:)
    @page = page
  end

  def view_template
    div(class: "story-page error-page") do
      section(class: "story-hero") do
        p(class: "story-kicker") { @page.fetch(:kicker) }
        p(class: "error-code", aria: { hidden: true }) { @page.fetch(:code) }
        h1(class: "story-title") { @page.fetch(:title) }
        p(class: "story-lead") { @page.fetch(:lead).squish }

        div(class: "story-actions") do
          @page.fetch(:actions).each do |action|
            link_to action.fetch(:text), public_send("#{action.fetch(:path)}_path"), class: "btn-#{action.fetch(:style)}"
          end
        end
      end
    end
  end
end
