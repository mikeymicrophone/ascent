class Views::OfficialCodes::IndexView < Views::ApplicationView
  prop :official_codes, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :parent, _Nilable(Policy)

  def view_template
    ResourceIndex(collection: @official_codes, pagy: @pagy, parent: @parent) { OfficialCodePartial(official_code: it) }
  end
end
