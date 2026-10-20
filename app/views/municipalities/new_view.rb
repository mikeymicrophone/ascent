class Views::Municipalities::NewView < Views::ApplicationView
  def initialize(municipality:)
    @municipality = municipality
  end

  def view_template(&)
    div(class: "scaffold municipality-new", id: dom_id(@municipality, :new)) do
      h1 { "New municipality" }
      
      Views::Municipalities::MunicipalityForm(municipality: @municipality)
      
      div do
        link_to "Back to municipalities", 
                municipalities_path,
                class: "secondary"
      end
    end
  end
end