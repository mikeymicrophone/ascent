# frozen_string_literal: true

class Views::Countries::ShowView < Views::ApplicationView
  
  def initialize(country:, notice: nil)
    @country = country
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold country-show", id: dom_id(@country, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing country" }
      
      render Views::CountryPartial.new(country: @country)
      
      div do
        link_to "Edit this country", 
                edit_country_path(@country),
                class: "secondary"
        link_to "Back to countries", 
                countries_path,
                class: "secondary"
        button_to "Destroy this country", 
                  @country,
                  method: :delete,
                  class: "danger",
                  data: { turbo_confirm: "Are you sure?" }
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