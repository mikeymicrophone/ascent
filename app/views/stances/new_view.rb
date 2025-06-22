class Views::Stances::NewView < Views::ApplicationView
  def initialize(stance:)
    @stance = stance
  end

  def view_template(&)
    div(class: "scaffold stance-new", id: dom_id(@stance, :new)) do
      h1 { "New stance" }
      
      Views::Stances::StanceForm(stance: @stance)
      
      div do
        link_to "Back to stances", 
                stances_path,
                class: "secondary"
      end
    end
  end
end