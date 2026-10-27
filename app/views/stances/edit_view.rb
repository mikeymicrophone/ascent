class Views::Stances::EditView < Views::ApplicationView
  prop :stance, Stance

  def view_template
    ResourceFormPage(record: @stance) { render Views::Stances::StanceForm.new(@stance) }
  end
end
