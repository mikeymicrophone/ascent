class Views::Stances::NewView < Views::ApplicationView
  prop :stance, Stance

  def view_template
    ResourceFormPage(record: @stance) { render Views::Stances::StanceForm.new(@stance) }
  end
end
