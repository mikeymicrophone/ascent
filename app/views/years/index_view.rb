class Views::Years::IndexView < Views::ApplicationView
  prop :years, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @years, pagy: @pagy) { YearPartial(year: it) }
  end
end
