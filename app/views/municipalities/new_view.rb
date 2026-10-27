class Views::Municipalities::NewView < Views::ApplicationView
  prop :municipality, Municipality

  def view_template
    ResourceFormPage(record: @municipality) { render Views::Municipalities::MunicipalityForm.new(@municipality) }
  end
end
