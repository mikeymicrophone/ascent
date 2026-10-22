class Views::AreaOfConcerns::ShowView < Views::ApplicationView
  prop :area_of_concern, AreaOfConcern

  def view_template
    ResourceShow(record: @area_of_concern) { AreaOfConcernPartial(area_of_concern: @area_of_concern) }
  end
end
