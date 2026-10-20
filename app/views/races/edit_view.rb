class Views::Races::EditView < Views::ApplicationView
  def initialize(race:)
    @race = race
  end

  def view_template(&)
    div(class: "scaffold race-edit", id: dom_id(@race, :edit)) do
      h1 { "Editing race" }
      
      Views::Races::RaceForm(race: @race)
      
      div do
        link_to "Show this race", 
                @race,
                class: "secondary"
        link_to "Back to races", 
                races_path,
                class: "secondary"
      end
    end
  end
end