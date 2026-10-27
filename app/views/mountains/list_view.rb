# frozen_string_literal: true

# The mountain as rows: a slider per candidate with the baseline marked across every track. It is also
# how the mountain reads on a phone. Sliders feed the same hidden inputs as the chart.
class Views::Mountains::ListView < Views::ApplicationView
  def initialize(mountain_data:, baseline:)
    @mountain_data = mountain_data
    @baseline = baseline
  end

  def view_template
    div(class: "rating-list", style: "--baseline: #{(@baseline || 250) / 5.0}%") do
      baseline_row
      @mountain_data.each { candidate_row(it) }
    end
  end

  private

  def baseline_row
    div(class: "rating-row baseline-row") do
      div(class: "rating-row-name") do
        span(class: "rating-row-label") { "Your baseline" }
        span(class: "rating-row-sub") { "Above it means approved" }
      end
      input(type: "range", min: 0, max: 500, step: 5, value: @baseline || 250, class: "rating-slider baseline-slider",
        aria: { label: "Baseline. Candidates rated above it are approved." },
        data: { action: "input->mountain-editor#setBaselineFromSlider", role: "baseline-slider" })
      span(class: "rating-row-value", data: { role: "baseline-value" }) { @baseline&.to_s || "—" }
    end
  end

  def candidate_row(data)
    candidacy = data[:candidacy]
    div(class: "rating-row", data: { role: "rating-row", candidacy_id: candidacy.id, state: row_state(data), off_ballot: candidacy.primary_candidacy_id.present? }) do
      div(class: "rating-row-name") do
        span(class: "rating-row-label") { candidacy.person.full_name }
        span(class: "rating-row-sub") { candidacy.ballot_summary.to_s }
      end
      input(type: "range", min: 0, max: 500, step: 5, value: data[:rating_value], class: "rating-slider",
        aria: { label: "Rate #{candidacy.person.full_name}" },
        data: { action: "input->mountain-editor#rateFromSlider", candidacy_id: candidacy.id, role: "rating-slider" })
      span(class: "rating-row-value", data: { role: "row-value" }) { data[:has_rating] ? data[:rating_value].to_s : "—" }
    end
  end

  def row_state(data)
    return "unrated" unless data[:has_rating]

    data[:is_approved] ? "approved" : "not-approved"
  end
end
