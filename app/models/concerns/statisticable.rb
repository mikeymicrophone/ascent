# frozen_string_literal: true

module Statisticable
  extend ActiveSupport::Concern

  def electorate_stats_for(item)
    case item
    when Country
      {
        voters: item.voters.count,
        active_elections: item.active_elections_count,
        total_offices: item.total_offices_count
      }
    when State
      {
        voters: item.voters.count,
        active_elections: item.active_elections_count,
        total_offices: item.total_offices_count
      }
    when City
      {
        voters: item.voters.count,
        active_elections: item.active_elections.count,
        total_offices: item.offices.count
      }
    else
      { voters: 0, active_elections: 0, total_offices: 0 }
    end
  end

  def calculate_comprehensive_stats(item)
    electorate_stats = electorate_stats_for(item)

    case item
    when Country
      electorate_stats.merge({
        total_states: item.states.count,
        total_cities: item.states.joins(:cities).count
      })
    when State
      electorate_stats.merge({
        total_cities: item.cities.count
      })
    when City
      electorate_stats
    else
      electorate_stats
    end
  end

  def humanize_stat_label(key)
    case key
    when :voters
      "Voters"
    when :active_elections
      "Active Elections"
    when :total_offices
      "Offices"
    when :total_states
      "States"
    when :total_cities
      "Cities"
    else
      key.to_s.humanize
    end
  end
end