class Views::Municipalities::EditView < Views::ApplicationView
  def initialize(municipality:)
    @municipality = municipality
  end

  def view_template(&)
    div(class: "scaffold municipality-edit", id: dom_id(@municipality, :edit)) do
      h1 { "Editing municipality" }
      
      Views::Municipalities::MunicipalityForm(municipality: @municipality)
      
      div do
        link_to "Show this municipality", 
                @municipality,
                class: "secondary"
        link_to "Back to municipalities", 
                municipalities_path,
                class: "secondary"
      end
    end
  end
end