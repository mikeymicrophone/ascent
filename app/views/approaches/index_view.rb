class Views::Approaches::IndexView < Views::ApplicationView
  prop :approaches, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @approaches, pagy: @pagy) { ApproachPartial(approach: it) }
  end
end
