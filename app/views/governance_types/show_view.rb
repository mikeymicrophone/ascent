class Views::GovernanceTypes::ShowView < Views::ApplicationView
  def initialize(governance_type:)
    @governance_type = governance_type
  end

  def view_template(&)
    div(class: "scaffold governance_type-show", id: dom_id(@governance_type, :show)) do
      h1 { "Showing governance type" }

      GovernanceTypePartial(governance_type: @governance_type)

      Ui::ResourceActions(resource: @governance_type)
    end
  end
end
