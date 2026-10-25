# frozen_string_literal: true

class Views::Components::Pagination < Views::ApplicationView
  def initialize(pagy:)
    @pagy = pagy
  end

  def view_template
    return unless @pagy&.last&.> 1

    div(class: "pagination-container") do
      # Page information
      div(class: "pagination-info") do
        raw @pagy.info_tag.html_safe
      end

      # Navigation links with custom Tailwind CSS
      div(class: "pagination-nav") do
        raw @pagy.series_nav.html_safe
      end
    end
  end
end
