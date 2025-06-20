class Views::Residences::NewView < Views::ApplicationView
  def initialize(residence:)
    @residence = residence
  end

  def view_template(&)
    div(class: "scaffold residence-new", id: dom_id(@residence, :new)) do
      h1 { "New residence" }
      
      render Views::Residences::ResidenceForm.new(residence: @residence)
      
      div do
        link_to "Back to residences", 
                residences_path,
                class: "secondary"
      end
    end
  end
end