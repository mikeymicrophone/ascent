# frozen_string_literal: true

class Views::Mountains::ShowView < Views::ApplicationView
  def initialize(election:, voter:, baseline:, mountain_data:)
    @election = election
    @voter = voter
    @baseline = baseline
    @mountain_data = mountain_data
  end

  def view_template
    div(class: "mountain-show") do
      render_header
      render Views::Mountains::MountainChart.new(
        election: @election,
        voter: @voter,
        baseline: @baseline,
        mountain_data: @mountain_data
      )
      render_controls
    end
  end

  private

  def render_header
    div(class: "mountain-header") do
      h1(class: "election-title") { @election.name }
      
      div(class: "voter-info") do
        p { "Voter: #{@voter.name}" }
        if @baseline
          p { "Approval Baseline: #{@baseline.baseline}" }
        else
          p(class: "no-baseline") { "No baseline set" }
        end
      end
    end
  end

  def render_controls
    div(class: "mountain-controls") do
      link_to("Edit Ratings", edit_mountain_path(@election, voter_id: @voter.id), 
              class: "btn-primary")
      link_to("Simulate More Data", simulate_mountain_path(@election), 
              method: :post, class: "btn-secondary")
      link_to("Back to Elections", mountains_path, class: "btn-tertiary")
    end
  end
end