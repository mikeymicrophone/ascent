class Views::Stances::ShowView < Views::ApplicationView
  def initialize(stance:)
    @stance = stance
  end

  def view_template(&)
    div(class: "scaffold stance-show", id: dom_id(@stance, :show)) do
      h1 { "Showing stance" }

      StancePartial(stance: @stance)

      Ui::ResourceActions(resource: @stance)
    end
  end
end
