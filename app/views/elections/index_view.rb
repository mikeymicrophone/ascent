class Views::Elections::IndexView < Views::ApplicationView
  prop :elections, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @elections, pagy: @pagy) { ElectionPartial(election: it) }
  end
end
