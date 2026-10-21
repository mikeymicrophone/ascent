class Views::Districts::ShowView < Views::ApplicationView
  def initialize(district:)
    @district = district
  end

  def view_template(&)
    div(class: "scaffold district-show", id: dom_id(@district, :show)) do
      h1 { "Showing district" }

      DistrictPartial(district: @district)

      Ui::ResourceActions(resource: @district)
    end
  end
end
