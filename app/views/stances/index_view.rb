class Views::Stances::IndexView < Views::ApplicationView
  prop :stances, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @stances, pagy: @pagy) { StancePartial(stance: it) }
  end
end
