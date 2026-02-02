# frozen_string_literal: true

class Views::Mountains::BaselineIndicator < Views::Components::Base
  def initialize(baseline_value:, baseline_set:, editable: false)
    @baseline_value = baseline_value
    @baseline_set = baseline_set
    @editable = editable
  end

  def view_template
    div(
      class: baseline_classes,
      style: "top: #{baseline_position}px;",
      title: baseline_title,
      data: baseline_data
    ) do
      div(class: "baseline-line")
      div(class: baseline_label_classes) do
        span(data: { role: "baseline-label" }) { baseline_label }
      end
    end
  end

  private

  def baseline_position
    # Convert baseline value to CSS position (inverted for top-origin)
    Views::Mountains.calculate_label_position(@baseline_value)
  end

  def baseline_label
    return "Baseline: #{@baseline_value}" if @baseline_set
    "Baseline: not set"
  end

  def baseline_label_classes
    classes = ["baseline-label"]
    classes << "baseline-empty" unless @baseline_set
    classes.join(" ")
  end

  def baseline_title
    return "Approval Baseline: #{@baseline_value}" if @baseline_set
    "Approval Baseline: not set"
  end

  def baseline_classes
    classes = ["baseline-indicator"]
    classes << "editable" if @editable
    classes.join(" ")
  end

  def baseline_data
    return {} unless @editable

    {
      action: "pointerdown->mountain-editor#startBaselineDrag pointermove->mountain-editor#dragBaseline pointerup->mountain-editor#stopBaselineDrag pointercancel->mountain-editor#stopBaselineDrag",
      baseline_set: @baseline_set
    }
  end
end
