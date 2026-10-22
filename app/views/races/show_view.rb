class Views::Races::ShowView < Views::ApplicationView
  prop :race, Race

  def view_template
    ResourceShow(record: @race) { RacePartial(race: @race) }
  end
end
