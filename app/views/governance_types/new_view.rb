class Views::GovernanceTypes::NewView < Views::ApplicationView
  def initialize(governance_type:)
    @governance_type = governance_type
  end

  def view_template(&)
    div(class: "scaffold governance_type-new", id: dom_id(@governance_type, :new)) do
      h1 { "New governance type" }
      
      Views::GovernanceTypes::GovernanceTypeForm(governance_type: @governance_type)
      
      div do
        link_to "Back to governance types", 
                governance_types_path,
                class: "secondary"
      end
    end
  end
end