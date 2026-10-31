module AnalyticsTracking
  extend ActiveSupport::Concern

  included do
    helper_method :analytics_context
    before_action :capture_analytics_referral
  end

  private

  def analytics_context
    {
      page_type: "#{controller_name}.#{action_name}",
      record_id: params[:id] || @influencer&.id&.to_s,
      path: analytics_path(request.path),
      signed_in: voter_signed_in?,
      referral_id: (session[:analytics_referral_id] if session[:analytics_referral_visit] == ahoy.visit_token),
      enabled: !current_voter&.can_review? && cookies[:ascent_analytics_exclude] != "1"
    }.compact
  end

  def analytics_path(path)
    path.sub(%r{\A/(invite|influencers)/[^/]+}, '/\1/:token')
  end

  def track_analytics(name, properties = {})
    ahoy.track name, analytics_context.except(:enabled).merge(properties)
  end

  def track_signup(voter, method:)
    tracker = Ahoy::Tracker.new(controller: self, user: voter)
    return if tracker.exclude?

    tracker.authenticate(voter)
    properties = analytics_context.except(:enabled).merge(
      method: method, landing_path: analytics_path(URI.parse(tracker.visit&.landing_page || request.original_url).path),
      inviter_id: voter.received_invites.first&.inviter_id
    ).compact
    tracker.track "signup_completed", properties
    voter.received_invites.each do |invite|
      tracker.track "connection_created", properties.merge(
        connection_id: invite.id, inviter_id: invite.inviter_id, source: "invited_signup"
      )
    end
  end

  def capture_analytics_referral
    return unless params[:ref].is_a?(String) && params[:ref].match?(/\A[0-9a-f]{32}\z/)

    session[:analytics_referral_id] = params[:ref]
    session[:analytics_referral_visit] = ahoy.visit_token
  end
end
