class Views::Races::NewView < Views::ApplicationView
  def initialize(race:)
    @race = race
  end

  def view_template(&)
    div(class: "scaffold race-new", id: dom_id(@race, :new)) do
      h1 { "New race" }
      
      Views::Races::RaceForm(race: @race)
      
      div do
        link_to "Back to races", 
                races_path,
                class: "secondary"
      end
    end
  end
end