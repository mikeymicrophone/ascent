# frozen_string_literal: true

# What a race's saved mountains add up to, for residents or for visitors: totals only, never named voters.
# The approval tally sits beside the first-choice count the same mountains give. Charts come later;
# for now the numbers are tables.
class Views::RaceResults::ShowView < Views::ApplicationView
  GROUP_LABELS = { "resident" => "Residents", "visitor" => "Pretend voters" }.freeze

  prop :race, Race
  prop :group, String
  prop :summary, Hash

  def view_template
    div(class: "results-page") do
      results_strip
      div(class: "results-body") do
        results_header
        if @summary[:any_mountains]
          stat_tiles
          div(class: "results-columns") do
            tally
            two_methods
          end
          off_ballot
        else
          no_mountains
        end
        privacy_note
      end
    end
  end

  private

  def place
    @race.office.jurisdiction.name
  end

  def candidacies
    @candidacies ||= @race.candidacies.includes(:person).index_by(&:id)
  end

  def results_strip
    div(class: "mode-strip mode-results", role: "status") do
      div(class: "mode-strip-inner") do
        div(class: "mode-strip-main") do
          span(class: "mode-strip-label") { "Ascent results" }
          span(class: "mode-strip-text") { "Mountains built by #{place} #{@group == "resident" ? "residents" : "visitors"}. Not a poll, and not the official count." }
        end
        span(class: "mode-strip-note") { "Updates hourly" }
      end
    end
  end

  def results_header
    section(class: "results-header") do
      div(class: "results-heading") do
        nav(class: "breadcrumb", aria: { label: "Breadcrumb" }) do
          link_to @race.office.name, edit_mountain_path(@race), class: "breadcrumb-link"
          span(class: "breadcrumb-separator", aria: { hidden: true }) { "/" }
          span(aria: { current: "page" }) { "Results" }
        end
        h1(class: "display-title") { "What #{place} approves" }
      end
      nav(class: "group-toggle", aria: { label: "Whose mountains" }) do
        RaceResults::GROUPS.each do |group|
          link_to GROUP_LABELS.fetch(group), race_results_path(@race, group: group),
            class: "group-toggle-link#{" is-current" if group == @group}", aria: { current: (group == @group ? "page" : nil) }
        end
      end
    end
  end

  def stat_tiles
    div(class: "stat-tiles") do
      stat_tile(number(@summary[:mountain_count]), "#{GROUP_LABELS.fetch(@group).downcase} built a mountain for this race")
      stat_tile(@summary[:average_approvals].to_s, "candidates approved per mountain, on average")
      stat_tile("#{@summary[:multiple_approval_share].round}%", "approved more than one candidate")
      stat_tile(@summary[:median_baseline].to_s, "median baseline", modifier: "baseline")
    end
  end

  def stat_tile(value, label, modifier: nil)
    div(class: "stat-tile#{" stat-tile-#{modifier}" if modifier}") do
      span(class: "stat-tile-value") { value }
      span(class: "stat-tile-label") { label }
    end
  end

  def tally
    section(class: "results-card results-tally") do
      h2(class: "card-title") { "Approval tally" }
      table(class: "results-table") do
        thead do
          tr do
            th(scope: "col") { "#" }
            th(scope: "col") { "Candidate" }
            th(scope: "col", class: "numeric") { "Approved by" }
            th(scope: "col", class: "numeric") { "First choice of" }
          end
        end
        tbody do
          ranked_by(:approval_shares).each_with_index do |(candidacy_id, share), index|
            tr(class: ("is-leader" if index.zero?)) do
              td(class: "rank") { (index + 1).to_s }
              td { candidacies.fetch(candidacy_id).person.full_name }
              td(class: "numeric strong") { percent(share) }
              td(class: "numeric") { percent(@summary[:first_choice_shares].fetch(candidacy_id, 0)) }
            end
          end
        end
      end
    end
  end

  def two_methods
    approval_leader = ranked_by(:approval_shares).first&.first
    plurality_leader = ranked_by(:first_choice_shares).first&.first
    section(class: "results-card results-methods") do
      h2(class: "card-title") { "Same mountains, two methods" }
      p(class: "card-text") { methods_text(approval_leader, plurality_leader) }
    end
  end

  def methods_text(approval_leader, plurality_leader)
    return "No one has been approved yet." unless approval_leader && plurality_leader

    approval_name = candidacies.fetch(approval_leader).person.last_name
    plurality_name = candidacies.fetch(plurality_leader).person.last_name
    if approval_leader == plurality_leader
      "#{approval_name} leads either way: the most approved, and the most often rated highest."
    else
      "Count only each mountain's highest-rated candidate and #{plurality_name} leads. " \
        "Count every approval and #{approval_name}, accepted by more voters, leads instead."
    end
  end

  def off_ballot
    off = @summary[:off_ballot]
    return if off[:mountain_count].zero?

    section(class: "results-card results-off-ballot") do
      h2(class: "card-title") { "Off the ballot" }
      p(class: "card-text") { "Among #{number(off[:mountain_count])} who chose to show candidates from the primaries." }
      table(class: "results-table") do
        tbody do
          off[:approval_shares].sort_by { -it.last }.each do |candidacy_id, share|
            tr do
              td { candidacies.fetch(candidacy_id).person.full_name }
              td(class: "numeric strong") { percent(share) }
            end
          end
        end
      end
    end
  end

  def no_mountains
    section(class: "results-card results-withheld") do
      h2(class: "card-title") { "No mountains yet" }
      p(class: "card-text") { "Results appear as soon as someone saves a mountain for this race." }
      link_to "Build your mountain", edit_mountain_path(@race), class: "pill-button"
    end
  end

  def privacy_note
    section(class: "privacy-note") do
      icon(:lock)
      p do
        strong { "Totals only. " }
        plain "Ascent never shows who rated a candidate or how. People who build mountains choose to take part, " \
          "so these results describe them, not the whole electorate."
      end
    end
  end

  def ranked_by(key)
    @summary[key].sort_by { -it.last }
  end

  def percent(share)
    "#{share.round}%"
  end

  def number(value)
    ActiveSupport::NumberHelper.number_to_delimited(value)
  end
end
