class Views::Offices::IndexView < Views::ApplicationView
  def initialize(offices:, pagy: nil)
    @offices = offices
    @pagy = pagy
  end

  def view_template(&)
    div(class: "scaffold offices-index", id: "index_offices") do
      div do
        h1 { "Offices" }
        scaffold_new_resource_link "New office", new_office_path, record: Office
      end

      div(id: "offices") do
        if @offices.any?
          @offices.each do |office|
            div(id: dom_id(office, :list_item)) do
              OfficePartial(office: office)

              Ui::ResourceActions(resource: office)
            end
          end
        else
          p { "No offices found." }
        end
      end

      Views::Components::Pagination(pagy: @pagy) if @pagy
    end
  end
end
