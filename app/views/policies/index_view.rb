class Views::Policies::IndexView < Views::ApplicationView
  prop :policies, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :parent, _Nilable(GoverningBody)

  def view_template
    ResourceIndex(collection: @policies, pagy: @pagy, parent: @parent) { PolicyPartial(policy: it) }
  end
end
