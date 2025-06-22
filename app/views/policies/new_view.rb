class Views::Policies::NewView < Views::ApplicationView
  def initialize(policy:)
    @policy = policy
  end

  def view_template(&)
    div(class: "scaffold policy-new", id: dom_id(@policy, :new)) do
      h1 { "New policy" }
      
      Views::Policies::PolicyForm(policy: @policy)
      
      div do
        link_to "Back to policies", 
                policies_path,
                class: "secondary"
      end
    end
  end
end