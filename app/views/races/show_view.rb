class Views::Races::ShowView < Views::ApplicationView
  def initialize(race:, notice: nil)
    @race = race
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold race-show", id: dom_id(@race, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing race" }
      
      RacePartial(race: @race)
      
      Ui::ResourceActions(resource: @race)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end