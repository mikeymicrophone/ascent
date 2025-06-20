class Views::Residences::EditView < Views::ApplicationView
  def initialize(residence:)
    @residence = residence
  end

  def view_template(&)
    div(class: "scaffold residence-edit", id: dom_id(@residence, :edit)) do
      h1 { "Editing residence" }
      
      render Views::Residences::ResidenceForm.new(residence: @residence)
      
      div do
        link_to "Show this residence", 
                @residence,
                class: "secondary"
        link_to "Back to residences", 
                residences_path,
                class: "secondary"
      end
    end
  end
end