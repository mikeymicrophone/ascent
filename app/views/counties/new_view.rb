class Views::Counties::NewView < Views::ApplicationView
  prop :county, County

  def view_template
    ResourceFormPage(record: @county) { render Views::Counties::CountyForm.new(@county) }
  end
end
