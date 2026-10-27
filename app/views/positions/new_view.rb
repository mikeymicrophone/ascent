class Views::Positions::NewView < Views::ApplicationView
  prop :position, Position

  def view_template
    ResourceFormPage(record: @position) { render Views::Positions::PositionForm.new(@position) }
  end
end
