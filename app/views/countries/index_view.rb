# frozen_string_literal: true

class Views::Countries::IndexView < Views::ApplicationView
  
  def initialize(countries:, pagy: nil, notice: nil)
    @countries = countries
    @pagy = pagy
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold countries-index", id: dom_id(Country, :index)) do
      render_notice if @notice.present?
      
      div do
        h1 { "Countries" }
        scaffold_new_resource_link "New country", new_country_path, record: Country
      end

      div(id: "countries") do
        if @countries.any?
          @countries.each do |country|
            div(id: dom_id(country, :list_item)) do
              CountryPartial(country: country)
              
              Ui::ResourceActions(resource: country)
            end
          end
        else
          p { "No countries found." }
        end
      end

      Views::Components::Pagination(pagy: @pagy) if @pagy
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end
