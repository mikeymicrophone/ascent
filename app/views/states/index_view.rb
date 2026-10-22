class Views::States::IndexView < Views::ApplicationView
  prop :states, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @states, pagy: @pagy) { StatePartial(state: it) }
  end
end
