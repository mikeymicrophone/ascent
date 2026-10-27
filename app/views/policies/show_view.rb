class Views::Policies::ShowView < Views::ApplicationView
  prop :policy, Policy

  def view_template
    ResourceShow(record: @policy, heading: @policy.title) { PolicyPartial(policy: @policy) }
  end
end
