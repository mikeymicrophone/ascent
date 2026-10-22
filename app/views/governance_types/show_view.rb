class Views::GovernanceTypes::ShowView < Views::ApplicationView
  prop :governance_type, GovernanceType

  def view_template
    ResourceShow(record: @governance_type) { GovernanceTypePartial(governance_type: @governance_type) }
  end
end
