class Views::Years::EditView < Views::ApplicationView
  prop :year, Year

  def view_template
    ResourceFormPage(record: @year) { render Views::Years::YearForm.new(@year) }
  end
end
