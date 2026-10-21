class Views::GoverningBodies::ShowView < Views::ApplicationView
  def initialize(governing_body:)
    @governing_body = governing_body
  end

  def view_template(&)
    div(class: "scaffold governing_body-show", id: dom_id(@governing_body, :show)) do
      h1 { "Showing governing body" }

      render GoverningBodyPartial.new(governing_body: @governing_body)

      Ui::ResourceActions(resource: @governing_body)
    end
  end
end
