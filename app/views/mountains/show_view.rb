# frozen_string_literal: true

class Views::Mountains::ShowView < Views::ApplicationView
  def initialize(race:, voter:, baseline:, mountain_data:)
    @race = race
    @voter = voter
    @baseline = baseline
    @mountain_data = mountain_data
  end

  def view_template
    div(class: "mountain-show") do
      render_header
      if @mountain_data.empty?
        render_empty_state
      else
        Views::Mountains::MountainChart(
          race: @race,
          voter: @voter,
          baseline: @baseline,
          mountain_data: @mountain_data
        )
      end
      render_controls
    end
  end

  private

  def render_header
    div(class: "mountain-header") do
      h1(class: "election-title") { @race.name }

      div(class: "election-context") do
        span { "Election:" }
        whitespace
        link_to @race.election.name, @race.election, class: "link"
      end

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

  def render_empty_state
    div(class: "mountain-empty") do
      p { "No candidates yet for this race." }
      div(class: "mountain-empty-actions") do
        link_to simulate_mountain_path(@race), data: { turbo_method: :post }, class: "resource-action resource-action-simulate" do
          Ui::ActionIcon(kind: :simulate)
          span { "Simulate Data" }
        end
        link_to("Back to Race", @race, class: "btn-tertiary")
      end
    end
  end

  def render_controls
    div(class: "mountain-controls") do
      link_to("Edit Ratings", edit_mountain_path(@race, voter_id: @voter.id),
              class: "btn-primary")
      link_to simulate_mountain_path(@race), data: { turbo_method: :post }, class: "resource-action resource-action-simulate" do
        Ui::ActionIcon(kind: :simulate)
        span { "Simulate More Data" }
      end
      link_to("Back to Races", mountains_path, class: "btn-tertiary")
    end
  end
end
