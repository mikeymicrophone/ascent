class Views::GovernanceTypes::EditView < Views::ApplicationView
  prop :governance_type, GovernanceType

  def view_template
    ResourceFormPage(record: @governance_type) { render Views::GovernanceTypes::GovernanceTypeForm.new(@governance_type) }
  end
end
