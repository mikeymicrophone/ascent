class Views::Residences::ShowView < Views::ApplicationView
  def initialize(residence:)
    @residence = residence
  end

  def view_template(&)
    div(class: "scaffold residence-show", id: dom_id(@residence, :show)) do
      h1 { "Showing residence" }

      render ResidencePartial.new(residence: @residence)

      Ui::ResourceActions(resource: @residence)
    end
  end
end
