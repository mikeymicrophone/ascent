# frozen_string_literal: true

class Views::Mountains::MountainChart < Views::Components::Base
  def initialize(election:, voter:, baseline:, mountain_data:)
    @election = election
    @voter = voter
    @baseline = baseline
    @mountain_data = mountain_data
  end

  def view_template
    div(class: "mountain-chart") do
      render Views::Mountains::YAxisLabels.new
      
      div(class: "chart-content") do
        render Views::Mountains::BaselineIndicator.new(baseline: @baseline) if @baseline
        
        div(class: "candidate-columns") do
          @mountain_data.each do |data|
            render Views::Mountains::CandidateColumn.new(
              candidacy: data[:candidacy],
              rating_value: data[:rating_value],
              has_rating: data[:has_rating],
              is_approved: data[:is_approved],
              position_y: data[:position_y]
            )
          end
        end
      end
    end
  end
end