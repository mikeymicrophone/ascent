class Views::Invites::IndexView < Views::ApplicationView
  prop :influencers, ActiveRecord::Relation
  prop :pagy, Pagy
  prop :connected_ids, Array

  def view_template
    rank = @pagy.from - 1
    IndexPage(title: "Invites leaderboard", records: @influencers, pagy: @pagy, noun: "influencer", frame: "invites-list",
      lede: "Voters bringing people to Ascent. You can connect to more than one influencer. Private influencers appear anonymously.",
      empty_title: "No invites yet", empty_text: "Share your invite link from your Profile to invite the first voters.") do |influencer|
      rank += 1
      li(class: "list-row") do
        span(class: "list-row-icon", aria: { label: "Rank #{rank}" }) { rank.to_s }
        div(class: "list-row-main") do
          if influencer.public_influencer? && influencer.publicly_visible_to?(current_voter)
            link_to influencer.full_name, influencer_path(token: influencer.invite_token), class: "list-row-title"
          else
            span(class: "list-row-title") { "Anonymous influencer" }
          end
          span(class: "list-row-meta") { pluralize(influencer.invite_count, "connected voter") }
        end
        div(class: "list-row-badges") do
          InfluencerConnection(influencer: influencer, connected: @connected_ids.include?(influencer.id), source: "leaderboard")
        end
      end
    end
  end
end
