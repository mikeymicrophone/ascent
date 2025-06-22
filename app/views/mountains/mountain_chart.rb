# frozen_string_literal: true

class Views::Mountains::MountainChart < Views::Components::Base
  def initialize(election:, voter: nil, baseline: nil, mountain_data: nil)
    @election = election
    @voter = voter
    @baseline = baseline
    @mountain_data = mountain_data
    @candidacies = []
  end

  def view_template(&block)
    if block
      vanish(&block)
    elsif @mountain_data
      populate_from_mountain_data
    end
    
    div(class: "mountain-chart") do
      Views::Mountains::YAxisLabels()
      
      div(class: "chart-content") do
        Views::Mountains::BaselineIndicator(baseline: @baseline) if @baseline
        
        div(class: "candidate-columns") do
          @candidacies.each do |candidacy_data|
            Views::Mountains::CandidateColumn(
              candidacy: candidacy_data[:candidacy],
              rating_value: candidacy_data[:rating_value],
              has_rating: candidacy_data[:has_rating],
              is_approved: candidacy_data[:is_approved],
              position_y: candidacy_data[:position_y]
            )
          end
        end
      end
    end
  end

  def candidacy(candidacy, rating: 0, approved: false, has_rating: false)
    position_y = Views::Mountains.calculate_label_position(rating)
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
end