class Views::Offices::IndexView < Views::ApplicationView
  prop :offices, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @offices, pagy: @pagy) { OfficePartial(office: it) }
  end
end
