class Views::AreaOfConcerns::NewView < Views::ApplicationView
  prop :area_of_concern, AreaOfConcern

  def view_template
    ResourceFormPage(record: @area_of_concern) { render Views::AreaOfConcerns::AreaOfConcernForm.new(@area_of_concern) }
  end
end
