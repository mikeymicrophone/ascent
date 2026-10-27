# frozen_string_literal: true

class Views::Mountains::MountainChart < Views::ApplicationView
  def initialize(race:, voter: nil, baseline: nil, mountain_data: nil, editable: false)
    @race = race
    @voter = voter
    @baseline = baseline
    @mountain_data = mountain_data
    @editable = editable
    @candidacies = []
  end

  def view_template(&block)
    if block
      vanish(&block)
    elsif @mountain_data
      populate_from_mountain_data
    end

    div(class: chart_classes, data: chart_data) do
      YAxisLabels()

      div(class: "chart-content") do
        BaselineIndicator(
          baseline_value: baseline_value,
          baseline_set: baseline_set?,
          editable: @editable
        ) if show_baseline?

        div(class: "candidate-columns") do
          @candidacies.each do |candidacy_data|
            CandidateColumn(
              candidacy: candidacy_data[:candidacy],
              rating_value: candidacy_data[:rating_value],
              has_rating: candidacy_data[:has_rating],
              is_approved: candidacy_data[:is_approved],
              baseline: (baseline_value if baseline_set?),
              editable: @editable,
              rating_input_id: rating_input_id(candidacy_data[:candidacy])
            )
          end
        end
      end
    end
  end

  def candidacy(candidacy, rating: 0, approved: false, has_rating: false)
    @candidacies << {
      candidacy: candidacy,
      rating_value: rating,
      has_rating: has_rating,
      is_approved: approved
    }
    nil
  end

  private

  def populate_from_mountain_data
    return unless @mountain_data

    @mountain_data.each do |data|
      candidacy(
        data[:candidacy],
        rating: data[:rating_value],
        approved: data[:is_approved],
        has_rating: data[:has_rating]
      )
    end
  end

  def vanish(&block)
    yield(self) if block
  end

  # The baseline is a number from 0 to 500, or nil until the voter sets one.
  def baseline_value
    @baseline || (250 if @editable)
  end

  def show_baseline?
    @editable || @baseline.present?
  end

  def baseline_set?
    @baseline.present?
  end

  def rating_input_id(candidacy)
    return nil unless @editable
    "rating-input-#{candidacy.id}"
  end

  def chart_classes
    classes = [ "mountain-chart" ]
    classes << "editable" if @editable
    classes.join(" ")
  end

  def chart_data
    range = {
      controller: "mountain-range",
      "mountain-range-baseline-value": baseline_value,
      "mountain-range-baseline-set-value": baseline_set?,
      action: "mountain-editor:rated->mountain-range#rate mountain-editor:baseline-moved->mountain-range#moveBaseline"
    }
    return range unless @editable

    range.merge("mountain-editor-target": "chart")
  end
end
