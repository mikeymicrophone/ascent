class Views::Approaches::IndexView < Views::ApplicationView
  prop :approaches, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :parent, _Nilable(Issue)

  def view_template
    ResourceIndex(collection: @approaches, pagy: @pagy, parent: @parent) { ApproachPartial(approach: it) }
  end
end
