class Views::Residences::IndexView < Views::ApplicationView
  prop :residences, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @residences, pagy: @pagy) { ResidencePartial(residence: it) }
  end
end
