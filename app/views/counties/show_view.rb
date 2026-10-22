class Views::Counties::ShowView < Views::ApplicationView
  prop :county, County

  def view_template
    ResourceShow(record: @county) { CountyPartial(county: @county) }
  end
end
