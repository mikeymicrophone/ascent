# frozen_string_literal: true

class Views::Components::CommunicationGallery < Views::ApplicationView
  prop :communications, _Any

  def view_template
    return if @communications.empty?

    section(class: "place-section", id: "profile-communications") do
      section_heading("Videos and statements", pluralize(@communications.size, "publication"))
      div(class: "communication-gallery") { @communications.each { communication_card(it) } }
    end
  end

  private

  def communication_card(communication)
    article(class: "communication-card") do
      if communication.embed_url
        embed_player(communication)
      elsif communication.video_file?
        video(class: "communication-player", src: communication.url, controls: true, playsinline: true, preload: "none",
          aria: { label: communication.name }) { "Your browser cannot play this video. Open the source below." }
      end
      div(class: "communication-card-body") do
        span(class: "communication-meta") do
          [ communication.kind.humanize, communication.channel&.name, communication.published_on.strftime("%b %-d, %Y") ].compact.join(" · ")
        end
        h3(class: "communication-title") { communication.name }
        p(class: "card-text") { communication.summary } if communication.summary.present?
        if communication.availability == "removed"
          p(class: "communication-unavailable") { "The original publication is no longer available." }
        end
        a(href: communication.url, class: "text-link", target: "_blank", rel: "noopener noreferrer") do
          plain "Open original"
          icon(:external_link)
        end
        if communication.archived_url.present?
          a(href: communication.archived_url, class: "text-link", target: "_blank", rel: "noopener noreferrer") { "Archived copy" }
        end
      end
    end
  end

  def embed_player(communication)
    div(class: "communication-embed", data: { controller: "media-player" }) do
      div(data: { "media-player-target": "container" }) do
        button(type: "button", class: "communication-play", data: { action: "media-player#play" },
          aria: { label: "Play #{communication.name}" }) do
          icon(:play)
          span { "Play video" }
          span(class: "communication-play-provider") { URI.parse(communication.embed_url).host.include?("vimeo") ? "Vimeo" : "YouTube" }
        end
      end
      template(data: { "media-player-target": "player" }) do
        iframe(src: communication.embed_url, title: communication.name, class: "communication-player", allowfullscreen: true,
          allow: "autoplay; encrypted-media; picture-in-picture; fullscreen", referrerpolicy: "strict-origin-when-cross-origin")
      end
    end
  end
end
