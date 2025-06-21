class Views::GovernanceTypes::EditView < Views::ApplicationView
  def initialize(governance_type:)
    @governance_type = governance_type
  end

  def view_template(&)
    div(class: "scaffold governance_type-edit", id: dom_id(@governance_type, :edit)) do
      h1 { "Editing governance type" }
      
      Views::GovernanceTypes::GovernanceTypeForm(governance_type: @governance_type)
      
      div do
        link_to "Show this governance type", 
                @governance_type,
                class: "secondary"
        link_to "Back to governance types", 
                governance_types_path,
                class: "secondary"
      end
    end
  end
end