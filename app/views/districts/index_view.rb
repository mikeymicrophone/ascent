class Views::Districts::IndexView < Views::ApplicationView
  prop :districts, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @districts, pagy: @pagy) { DistrictPartial(district: it) }
  end
end
