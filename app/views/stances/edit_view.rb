class Views::Stances::EditView < Views::ApplicationView
  def initialize(stance:)
    @stance = stance
  end

  def view_template(&)
    div(class: "scaffold stance-edit", id: dom_id(@stance, :edit)) do
      h1 { "Editing stance" }
      
      Views::Stances::StanceForm(stance: @stance)
      
      div do
        link_to "Show this stance", 
                @stance,
                class: "secondary"
        link_to "Back to stances", 
                stances_path,
                class: "secondary"
      end
    end
  end
end