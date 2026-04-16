class PagesController < ApplicationController
  def home
    render Views::Pages::HomeView.new(
      active_elections: active_elections,
      metrics: project_metrics
    )
  end

  def supporters
    render Views::Pages::SupportersView.new(
      active_elections: active_elections,
      metrics: project_metrics
    )
  end

  private

  def active_elections
    @active_elections ||= Election.active.includes(office: [:position, :jurisdiction]).recent.limit(3)
  end

  def project_metrics
    @project_metrics ||= {
      active_elections: Election.active.count,
      offices: Office.count,
      topics: Topic.count,
      issues: Issue.count
    }
  end
end
