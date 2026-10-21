class Views::AreaOfConcerns::ShowView < Views::ApplicationView
  def initialize(area_of_concern:)
    @area_of_concern = area_of_concern
  end

  def view_template(&)
    div(class: "scaffold area_of_concern-show", id: dom_id(@area_of_concern, :show)) do
      h1 { "Showing area of concern" }

      render AreaOfConcernPartial.new(area_of_concern: @area_of_concern)

      Ui::ResourceActions(resource: @area_of_concern)
    end
  end
end
