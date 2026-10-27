class Views::People::IndexView < Views::ApplicationView
  prop :people, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @people, pagy: @pagy) { PersonPartial(person: it) }
  end
end
