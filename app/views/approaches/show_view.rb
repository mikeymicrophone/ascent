class Views::Approaches::ShowView < Views::ApplicationView
  prop :approach, Approach

  def view_template
    ResourceShow(record: @approach) { ApproachPartial(approach: @approach) }
  end
end
