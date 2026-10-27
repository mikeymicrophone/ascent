class Views::Issues::IndexView < Views::ApplicationView
  prop :issues, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :parent, _Nilable(Topic)

  def view_template
    ResourceIndex(collection: @issues, pagy: @pagy, parent: @parent) { IssuePartial(issue: it) }
  end
end
