class Views::Residences::ShowView < Views::ApplicationView
  prop :residence, Residence

  def view_template
    ResourceShow(record: @residence) { ResidencePartial(residence: @residence) }
  end
end
