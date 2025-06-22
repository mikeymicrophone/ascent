# frozen_string_literal: true

class Views::Components::GeographicSummary < Views::ApplicationView
  include Statisticable

  def initialize(current_object:)
    @current_object = current_object
  end

  def view_template
    div(class: "geographic-summary") do
      h5 { "Geographic Summary" }

      div(class: "summary-grid") do
        calculate_comprehensive_stats(@current_object).each do |stat_key, stat_value|
          next if stat_value.zero?

          div(class: "summary-stat") do
            span(class: "summary-value") { stat_value }
            span(class: "summary-label") { humanize_stat_label(stat_key) }
          end
        end
      end
    end
  end
end