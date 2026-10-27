class Views::Years::ShowView < Views::ApplicationView
  prop :year, Year

  def view_template
    ResourceShow(record: @year) { YearPartial(year: @year) }
  end
end
