class Views::Approaches::ShowView < Views::ApplicationView
  def initialize(approach:)
    @approach = approach
  end

  def view_template(&)
    div(class: "scaffold approach-show", id: dom_id(@approach, :show)) do
      h1 { "Showing approach" }

      ApproachPartial(approach: @approach)

      Ui::ResourceActions(resource: @approach)
    end
  end
end
