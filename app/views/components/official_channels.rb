# frozen_string_literal: true

# A side card linking the official accounts a person or their campaigns speak through, if there are any.
#   OfficialChannels(owners: [ person, *person.candidacies ])
class Views::Components::OfficialChannels < Views::ApplicationView
  prop :owners, Array

  def view_template
    channels = Channel.official.where(owner: @owners).order(:platform).to_a
    return if channels.empty?

    SideCard(heading: "Official channels") do
      ul(class: "nearby-list") { channels.each { |channel| li { channel_link(channel) } } }
    end
  end

  private

  def channel_link(channel)
    label = "#{channel.handle} · #{channel.platform.humanize}"
    return plain(label) if channel.url.blank?

    a(href: channel.url, class: "text-link", target: "_blank", rel: "noopener") { label }
  end
end
