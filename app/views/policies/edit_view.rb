class Views::Policies::EditView < Views::ApplicationView
  def initialize(policy:)
    @policy = policy
  end

  def view_template(&)
    div(class: "scaffold policy-edit", id: dom_id(@policy, :edit)) do
      h1 { "Editing policy" }
      
      Views::Policies::PolicyForm(policy: @policy)
      
      div do
        link_to "Show this policy", 
                @policy,
                class: "secondary"
        link_to "Back to policies", 
                policies_path,
                class: "secondary"
      end
    end
  end
end