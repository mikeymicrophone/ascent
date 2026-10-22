class Views::Positions::ShowView < Views::ApplicationView
  prop :position, Position

  def view_template
    ResourceShow(record: @position) { PositionPartial(position: @position) }
  end
end
