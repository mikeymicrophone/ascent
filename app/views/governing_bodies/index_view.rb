class Views::GoverningBodies::IndexView < Views::ApplicationView
  prop :governing_bodies, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :parent, _Nilable(GovernanceType)

  def view_template
    ResourceIndex(collection: @governing_bodies, pagy: @pagy, parent: @parent) { GoverningBodyPartial(governing_body: it) }
  end
end
