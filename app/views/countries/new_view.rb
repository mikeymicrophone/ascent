# frozen_string_literal: true

class Views::Countries::NewView < Views::ApplicationView
  
  def initialize(country:)
    @country = country
  end

  def view_template(&)
    div(class: "scaffold country-new", id: dom_id(@country, :new)) do
      h1 { "New country" }
      
      render Views::CountryForm.new(country: @country)
      
      div do
        link_to "Back to countries", 
                countries_path,
                class: "secondary"
      end
    end
  end
end