class Views::States::IndexView < Views::ApplicationView
  prop :states, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :parent, _Nilable(Country)

  def view_template
    ResourceIndex(collection: @states, pagy: @pagy, parent: @parent) { StatePartial(state: it) }
  end
end
