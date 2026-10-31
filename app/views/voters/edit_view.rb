class Views::Voters::EditView < Views::ApplicationView
  prop :voter, Voter

  def view_template
    ResourceFormPage(record: @voter) do
      render Views::Voters::VoterForm.new(@voter)
      if @voter == current_voter
        section(class: "place-section") do
          section_heading("Invite voters")
          p { "Share your invite link. Voters who register through it will be connected to you." }
          link_to invite_url(token: @voter.invite_token), invite_path(token: @voter.invite_token), class: "link"
          p { link_to "Invites leaderboard", invites_path, class: "link" }
          p { link_to "Edit influencer links and statements", influencer_profile_path, class: "link" }
          form_with(url: voter_path(@voter), method: :patch) do
            input(type: "hidden", name: "voter[public_influencer]", value: "0")
            label do
              input(type: "checkbox", name: "voter[public_influencer]", value: "1", checked: @voter.public_influencer?)
              plain "Make my influencer page public and show my name on the invites leaderboard"
            end
            p { "Your public page appears once you have invited at least one voter. Your invited voters remain private." }
            button(type: "submit", class: "primary") { "Save visibility" }
          end
          if @voter.public_influencer? && @voter.invites.exists?
            p { link_to "View my influencer page", influencer_path(token: @voter.invite_token), class: "link" }
          end
        end
      end
    end
  end
end
