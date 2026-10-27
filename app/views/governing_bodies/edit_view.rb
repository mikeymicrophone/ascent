class Views::GoverningBodies::EditView < Views::ApplicationView
  prop :governing_body, GoverningBody

  def view_template
    ResourceFormPage(record: @governing_body) { render Views::GoverningBodies::GoverningBodyForm.new(@governing_body) }
  end
end
