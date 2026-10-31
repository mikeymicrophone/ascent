class Views::Components::InfluencerConnection < Views::ApplicationView
  prop :influencer, Voter
  prop :connected, _Boolean
  prop :source, String

  def view_template
    return unless @influencer.public_influencer?

    if @influencer == current_voter
      span(class: "row-badge") { "You" }
    elsif @connected
      span(class: "row-badge") { "Connected" }
    elsif current_voter
      button_to "Connect", invites_path, params: { token: @influencer.invite_token, source: @source }, class: "secondary"
    else
      link_to "Sign in to connect", new_voter_session_path, class: "link"
    end
  end
end
