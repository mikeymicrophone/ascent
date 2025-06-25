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
      
      CountryPartial(country: @country)
      
      Ui::ResourceActions(resource: @country)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end