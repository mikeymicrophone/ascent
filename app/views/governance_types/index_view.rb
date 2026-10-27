class Views::GovernanceTypes::IndexView < Views::ApplicationView
  prop :governance_types, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @governance_types, pagy: @pagy) { GovernanceTypePartial(governance_type: it) }
  end
end
