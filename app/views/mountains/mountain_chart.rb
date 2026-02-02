# frozen_string_literal: true

class Views::Mountains::MountainChart < Views::ApplicationView
  def initialize(election:, voter: nil, baseline: nil, mountain_data: nil, editable: false)
    @election = election
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
        ) if baseline_value
        
        div(class: "candidate-columns") do
          @candidacies.each do |candidacy_data|
            CandidateColumn(
              candidacy: candidacy_data[:candidacy],
              rating_value: candidacy_data[:rating_value],
              has_rating: candidacy_data[:has_rating],
              is_approved: candidacy_data[:is_approved],
              position_y: candidacy_data[:position_y],
              editable: @editable,
              rating_input_id: rating_input_id(candidacy_data[:candidacy])
            )
          end
        end
      end
    end
  end

  def candidacy(candidacy, rating: 0, approved: false, has_rating: false)
    position_y = calculate_label_position(rating)
    @candidacies << {
      candidacy: candidacy,
      rating_value: rating,
      has_rating: has_rating,
      is_approved: approved,
      position_y: position_y
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

  def baseline_value
    return @baseline.baseline if @baseline
    return 250 if @editable
    nil
  end

  def baseline_set?
    @baseline.present?
  end

  def rating_input_id(candidacy)
    return nil unless @editable
    "rating-input-#{candidacy.id}"
  end

  def chart_classes
    classes = ["mountain-chart"]
    classes << "editable" if @editable
    classes.join(" ")
  end

  def chart_data
    return {} unless @editable
    { "mountain-editor-target": "chart" }
  end
end
