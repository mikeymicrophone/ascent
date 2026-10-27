class Views::Voters::IndexView < Views::ApplicationView
  prop :voters, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @voters, pagy: @pagy) { VoterPartial(voter: it) }
  end
end
