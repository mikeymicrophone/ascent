class Views::Mountains::Sharing < Views::ApplicationView
  prop :mountain, Mountain

  def view_template
    publication = @mountain.publication
    section(class: "mountain-sharing", aria: { label: "Sharing" }) do
      h2(class: "card-heading") { "Sharing" }
      if publication
        p { "This mountain is public. Anyone with the link can see your name, saved ratings, and baseline. Saved changes update the public mountain." }
        div(class: "mountain-sharing-actions", data: { controller: "share", share_url_value: public_mountain_url(publication), share_title_value: publication.title,
          share_target_type_value: "public_mountain", share_target_id_value: publication.id }) do
          button(type: "button", class: "pill-button pill-button-summit", data: { action: "share#share" }) { "Share mountain" }
          span(role: "status", data: { share_target: "status" })
          link_to "View public mountain", public_mountain_path(publication), class: "text-link"
        end
        button_to "Make private", share_mountain_path(@mountain.race), method: :delete, class: "pill-button pill-button-outline"
        p { "Making it private removes the public page and image from Ascent. Social sites may keep copies already shared." }
      else
        p { "Your mountain is private. Making it public shares your name, saved ratings, and baseline. Unsaved changes stay private." }
        button_to "Make public", share_mountain_path(@mountain.race), class: "pill-button pill-button-outline"
      end
    end
  end
end
