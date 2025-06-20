# frozen_string_literal: true

class Views::Mountains::EditView < Views::ApplicationView
  def initialize(election:, voter:, baseline:, mountain_data:)
    @election = election
    @voter = voter
    @baseline = baseline
    @mountain_data = mountain_data
  end

  def view_template
    div(class: "mountain-edit") do
      render_header
      
      div(class: "edit-instructions") do
        p { "Click on candidate columns to rate them, or drag the baseline to adjust your approval threshold." }
      end
      
      render MountainChart.new(
        election: @election,
        voter: @voter,
        baseline: @baseline,
        mountain_data: @mountain_data
      )
      
      render_save_controls
    end
  end

  private

  def render_header
    div(class: "mountain-header") do
      h1(class: "election-title") { "Edit Ratings: #{@election.name}" }
      
      div(class: "voter-info") do
        p { "Voter: #{@voter.name}" }
        if @baseline
          p { "Current Baseline: #{@baseline.baseline}" }
        else
          p(class: "no-baseline") { "No baseline set - ratings will default to disapproved" }
        end
      end
    end
  end

  def render_save_controls
    div(class: "save-controls") do
      link_to("Save Changes", mountain_path(@election, voter_id: @voter.id), 
              class: "btn-primary")
      link_to("Cancel", mountain_path(@election, voter_id: @voter.id), 
              class: "btn-secondary")
    end
  end
end