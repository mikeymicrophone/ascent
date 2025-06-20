# frozen_string_literal: true

class Views::Countries::EditView < Views::ApplicationView
  
  def initialize(country:)
    @country = country
  end

  def view_template(&)
    div(class: "scaffold country-edit", id: dom_id(@country, :edit)) do
      h1 { "Editing country" }
      
      Views::Countries::CountryForm(country: @country)
      
      div do
        link_to "Show this country", 
                @country,
                class: "secondary"
        link_to "Back to countries", 
                countries_path,
                class: "secondary"
      end
    end
  end
end