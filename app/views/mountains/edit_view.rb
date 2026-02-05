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
      
      form_with(
        url: mountain_path(@election, voter_id: @voter.id),
        method: :patch,
        class: "mountain-form",
        data: {
          controller: "mountain-editor",
          "mountain-editor-max-height-value": Views::Mountains.max_height
        }
      ) do
        render_baseline_input
        render_rating_inputs

        if @mountain_data.empty?
          render_empty_state
        else
          render MountainChart.new(
            election: @election,
            voter: @voter,
            baseline: @baseline,
            mountain_data: @mountain_data,
            editable: true
          )
        end
        
        render_save_controls
      end
    end
  end

  private

  def render_header
    div(class: "mountain-header") do
      h1(class: "election-title") { "Edit Ratings: #{@election.name}" }

      div(class: "election-context") do
        span { "Election:" }
        whitespace
        link_to @election.name, @election, class: "link"
      end
      
      div(class: "voter-info") do
        p { "Voter: #{@voter.name}" }
        if @baseline
          p { "Current Baseline: #{@baseline.baseline}" }
        else
          p(class: "no-baseline") { "No baseline set yet - drag the baseline line to set one" }
        end
      end
    end
  end

  def render_save_controls
    div(class: "save-controls") do
      button(class: "btn-primary", type: "submit") { "Save Changes" }
      link_to("Cancel", mountain_path(@election, voter_id: @voter.id), 
              class: "btn-secondary")
    end
  end

  def render_empty_state
    div(class: "mountain-empty") do
      p { "No candidates yet for this election." }
      div(class: "mountain-empty-actions") do
        link_to("Simulate Data", simulate_mountain_path(@election),
                data: { turbo_method: :post }, class: "btn-primary")
        link_to("Back to Election", @election, class: "btn-tertiary")
      end
    end
  end

  def render_baseline_input
    input(
      type: "hidden",
      name: "baseline",
      value: @baseline&.baseline,
      data: { "mountain-editor-target": "baselineInput" }
    )
  end

  def render_rating_inputs
    @mountain_data.each do |data|
      input(
        type: "hidden",
        id: rating_input_id(data[:candidacy].id),
        name: "ratings[#{data[:candidacy].id}]",
        value: data[:has_rating] ? data[:rating_value] : nil
      )
    end
  end

  def rating_input_id(candidacy_id)
    "rating-input-#{candidacy_id}"
  end
end
