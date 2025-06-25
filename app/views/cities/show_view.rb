class Views::Cities::ShowView < Views::ApplicationView
  def initialize(city:, notice: nil)
    @city = city
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold city-show", id: dom_id(@city, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing city" }
      
      CityPartial(city: @city)
      
      Ui::ResourceActions(resource: @city)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end