class Views::Candidacies::IndexView < Views::ApplicationView
  prop :candidacies, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @candidacies, pagy: @pagy) { CandidacyPartial(candidacy: it) }
  end
end
