# frozen_string_literal: true

class Views::Components::QuickStats < Views::ApplicationView
  include Statisticable

  ELECTORATE_STATS = {
    voters: { label: "voters", kind: "voter-count" },
    active_elections: { label: "active elections", kind: "election-count" },
    total_offices: { label: "offices", kind: "office-count" }
  }.freeze

  def initialize(item:, custom_stats: [])
    @item = item
    @custom_stats = custom_stats
  end

  def view_template
    div(class: "quick-stats") do
      div(class: "stats-row") do
        electorate_stats.each { |key, value| Stat(value: value, **ELECTORATE_STATS[key]) }
        @custom_stats.each { Stat(value: it[:value], label: it[:label], kind: "custom-stat") }
      end
    end
  end

  private

  def electorate_stats
    electorate_stats_for(@item).select { |_key, value| value > 0 }
  end
end
