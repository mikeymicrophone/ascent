class Views::Municipalities::ShowView < Views::ApplicationView
  def initialize(municipality:)
    @municipality = municipality
  end

  def view_template(&)
    div(class: "scaffold municipality-show", id: dom_id(@municipality, :show)) do
      h1 { "Showing municipality" }

      MunicipalityPartial(municipality: @municipality)

      Ui::ResourceActions(resource: @municipality)
    end
  end
end
