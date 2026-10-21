class Views::Residences::IndexView < Views::ApplicationView
  def initialize(residences:, pagy: nil)
    @residences = residences
    @pagy = pagy
  end

  def view_template(&)
    div(class: "scaffold residences-index", id: "index_residences") do
      div do
        h1 { "Residences" }
        scaffold_new_resource_link "New residence", new_residence_path, record: Residence
      end

      div(id: "residences") do
        if @residences.any?
          @residences.each do |residence|
            div(id: dom_id(residence, :list_item)) do
              render ResidencePartial.new(residence: residence)

              Ui::ResourceActions(resource: residence)
            end
          end
        else
          p { "No residences found." }
        end
      end

      Views::Components::Pagination(pagy: @pagy) if @pagy
    end
  end
end
