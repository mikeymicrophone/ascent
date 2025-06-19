# frozen_string_literal: true

class Views::Countries::CountryPartial < Views::ApplicationView
  
  def initialize(country:)
    @country = country
  end

  def view_template(&)
    div(id: dom_id(@country), class: "country-partial") do
      h3 { @country.name }
      div do
        span { "Code:" }
        whitespace
        span { @country.code }
      end
      div do
        span { "Description:" }
        whitespace
        div(class: "mt-1") { simple_format(@country.description) }
      end
    end
  end
end