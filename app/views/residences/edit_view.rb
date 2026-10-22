class Views::Residences::EditView < Views::ApplicationView
  prop :residence, Residence

  def view_template
    ResourceFormPage(record: @residence) { render Views::Residences::ResidenceForm.new(@residence) }
  end
end
