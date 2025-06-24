module ApplicationHelper
  # Include Pagy frontend helpers for pagination support
  include Pagy::Frontend

  def link_to_name(resource)
    link_to resource.name, resource
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
      "Nunito" => "Nunito:ital,wght@0,200..1000;1,200..1000",
      "Caprasimo" => "Caprasimo",
      "Kanit" => "Kanit:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900",
      "WDXL Lubrifont JP N" => "WDXL+Lubrifont+JP+N",
      "Noto Serif Dives Akuru" => "Noto+Serif+Dives+Akuru"
    }
  end
end
