# frozen_string_literal: true

class Views::Countries::IndexView < Views::ApplicationView
  
  def initialize(countries:, notice: nil)
    @countries = countries
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold countries-index", id: dom_id(Country, :index)) do
      render_notice if @notice.present?
      
      div do
        h1 { "Countries" }
        link_to "New country", 
                new_country_path,
                class: "primary"
      end

      div(id: "countries") do
        if @countries.any?
          @countries.each do |country|
            div(id: dom_id(country, :list_item)) do
              render Views::Countries::CountryPartial.new(country: country)
              
              div do
                link_to "Show", country,
                        class: "secondary"
                link_to "Edit", edit_country_path(country),
                        class: "secondary"
                button_to "Destroy", country,
                          method: :delete,
                          class: "danger",
                          data: { turbo_confirm: "Are you sure?" }
              end
            end
          end
        else
          p { "No countries found." }
        end
      end
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end