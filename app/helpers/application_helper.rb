module ApplicationHelper
  # Include Pagy frontend helpers for pagination support
  include Pagy::Frontend
  include ScaffoldUiHelper

  def link_to_name(resource, options = {})
    link_to resource.name, resource, options
  end

  def load_google_fonts
    font_header +
    tag.link(rel: "stylesheet", href: font_url)
  end

  def font_header
    tag.link(rel: "preconnect", href: "https://fonts.googleapis.com") +
    tag.link(rel: "preconnect", href: "https://fonts.gstatic.com", crossorigin: true)
  end

  def font_url
    "https://fonts.googleapis.com/css2?family=" +
    font_list.values.join("&family=") + "&display=swap"
  end

  def font_list
    {
      "Source Serif 4" => "Source+Serif+4:opsz,wght@8..60,200..900",
      "Calistoga" => "Calistoga",
      "Sora" => "Sora:wght@100..800",
      "IBM Plex Mono" => "IBM+Plex+Mono:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;1,100;1,200;1,300;1,400;1,500;1,600;1,700"
    }
  end
end
