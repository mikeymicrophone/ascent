class Views::Influencers::ShowView < Views::ApplicationView
  prop :influencer, Voter
  prop :connected, _Boolean

  def view_template
    div(class: "index-page") do
      PageHeader(title: @influencer.full_name, eyebrow: "Influencer", trail: [ [ "Invites leaderboard", invites_path ] ],
        lede: pluralize(@influencer.invites.count, "connected voter"))
      links = @influencer.voter_links.active.to_a
      details(class: "place-section influencer-disclosure", id: "influencer-links") do
        summary(class: "card-title") { "Links (#{links.size})" }
        if links.any?
          ol(class: "influencer-content-list") do
            links.each do |link|
              li { link_to link.label, link.url, target: "_blank", rel: "nofollow noopener noreferrer", class: "link" }
            end
          end
        else
          p { "No links yet." }
        end
      end
      statements = @influencer.voter_statements.active.to_a
      details(class: "place-section influencer-disclosure", id: "influencer-statements") do
        summary(class: "card-title") { "Statements (#{statements.size})" }
        if statements.any?
          ol(class: "influencer-content-list") do
            statements.each { |statement| li { p(class: "whitespace-pre-wrap") { statement.body } } }
          end
        else
          p { "No statements yet." }
        end
      end
      section(class: "place-section") do
        p { "Connect to this influencer. You can stay connected to other influencers too." }
        InfluencerConnection(influencer: @influencer, connected: @connected, source: "influencer")
      end
    end
  end
end
