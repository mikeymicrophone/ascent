class Views::Countries::IndexView < Views::ApplicationView
  prop :countries, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @countries, pagy: @pagy) { CountryPartial(country: it) }
  end
end
