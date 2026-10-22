class Views::Approaches::NewView < Views::ApplicationView
  prop :approach, Approach

  def view_template
    ResourceFormPage(record: @approach) { render Views::Approaches::ApproachForm.new(@approach) }
  end
end
