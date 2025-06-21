# frozen_string_literal: true

class Views::Mountains::BaselineIndicator < Views::Components::Base
  def initialize(baseline:)
    @baseline = baseline
  end

  def view_template
    return unless @baseline

    div(
      class: "baseline-indicator",
      style: "top: #{baseline_position}px;",
      title: "Approval Baseline: #{@baseline.baseline}"
    ) do
      div(class: "baseline-line")
      div(class: "baseline-label") do
        span { "Baseline: #{@baseline.baseline}" }
      end
    end
  end

  private

  def baseline_position
    # Convert baseline value to CSS position (inverted for top-origin)
    Views::Mountains.calculate_label_position(@baseline.baseline)
  end
end