class Views::Races::EditView < Views::ApplicationView
  prop :race, Race

  def view_template
    ResourceFormPage(record: @race) { render Views::Races::RaceForm.new(@race) }
  end
end
