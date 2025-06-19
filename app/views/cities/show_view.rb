class Views::Cities::ShowView < Views::ApplicationView
  def initialize(city:, notice: nil)
    @city = city
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold city-show", id: dom_id(@city, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing city" }
      
      Views::Cities::CityPartial(city: @city)
      
      div do
        link_to "Edit this city", 
                edit_city_path(@city),
                class: "secondary"
        link_to "Back to cities", 
                cities_path,
                class: "secondary"
        button_to "Destroy this city", 
                  @city,
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