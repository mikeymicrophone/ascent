class Views::Positions::IndexView < Views::ApplicationView
  prop :positions, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @positions, pagy: @pagy) { PositionPartial(position: it) }
  end
end
