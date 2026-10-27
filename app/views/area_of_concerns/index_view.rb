class Views::AreaOfConcerns::IndexView < Views::ApplicationView
  prop :area_of_concerns, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @area_of_concerns, pagy: @pagy) { AreaOfConcernPartial(area_of_concern: it) }
  end
end
