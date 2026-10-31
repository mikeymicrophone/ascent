class PagesController < ApplicationController
  # Public pages, with no record to authorize.
  skip_verify_authorized

  def home
    render Views::Pages::HomeView.new(
      page: PageContent.load("home"),
      active_races: active_races,
      metrics: project_metrics
    )
  end

  def glossary
    render Views::Pages::GlossaryView.new(
      page: PageContent.load("glossary")
    )
  end

  def faq
    render Views::Pages::FaqView.new(
      page: PageContent.load("faq")
    )
  end

  def supporters
    render Views::Pages::SupportersView.new(
      page: PageContent.load("supporters"),
      active_races: active_races,
      metrics: project_metrics
    )
  end

  def approval_voting
    render Views::Pages::ApprovalVotingView.new(
      page: PageContent.load("approval_voting")
    )
  end

  def terms_of_service; end

  private

  def active_races
    @active_races ||= Race.active.with_naming_details.recent.limit(3)
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
