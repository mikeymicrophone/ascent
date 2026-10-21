class Views::Policies::ShowView < Views::ApplicationView
  def initialize(policy:)
    @policy = policy
  end

  def view_template(&)
    div(class: "scaffold policy-show", id: dom_id(@policy, :show)) do
      h1 { @policy.title }

      PolicyPartial(policy: @policy)

      Ui::ResourceActions(resource: @policy)
    end
  end
end
