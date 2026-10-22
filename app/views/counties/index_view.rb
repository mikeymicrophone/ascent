class Views::Counties::IndexView < Views::ApplicationView
  prop :counties, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @counties, pagy: @pagy) { CountyPartial(county: it) }
  end
end
