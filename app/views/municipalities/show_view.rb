class Views::Municipalities::ShowView < Views::ApplicationView
  prop :municipality, Municipality

  def view_template
    ResourceShow(record: @municipality) { MunicipalityPartial(municipality: @municipality) }
  end
end
