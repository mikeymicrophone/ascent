class Views::GovernanceTypes::GovernanceTypeForm < Views::Components::Forms::Base
  def view_template
    row field(:name).text
    row field(:description).textarea(rows: 4)
    row field(:decision_making_process).text
  end
end
