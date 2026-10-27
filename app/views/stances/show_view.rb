class Views::Stances::ShowView < Views::ApplicationView
  prop :stance, Stance

  def view_template
    ResourceShow(record: @stance) { StancePartial(stance: @stance) }
  end
end
