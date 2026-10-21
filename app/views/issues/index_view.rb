class Views::Issues::IndexView < Views::ApplicationView
  prop :issues, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @issues, pagy: @pagy) { IssuePartial(issue: it) }
  end
end
