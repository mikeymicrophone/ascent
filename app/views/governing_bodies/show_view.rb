class Views::GoverningBodies::ShowView < Views::ApplicationView
  prop :governing_body, GoverningBody

  def view_template
    ResourceShow(record: @governing_body) { GoverningBodyPartial(governing_body: @governing_body) }
  end
end
