class Views::Races::ShowView < Views::ApplicationView
  def initialize(race:)
    @race = race
  end

  def view_template(&)
    div(class: "scaffold race-show", id: dom_id(@race, :show)) do
      h1 { "Showing race" }

      RacePartial(race: @race)

      Ui::ResourceActions(resource: @race)
    end
  end
end
