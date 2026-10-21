class Views::Municipalities::IndexView < Views::ApplicationView
  def initialize(municipalities:, pagy: nil, filtered_state: nil)
    @municipalities = municipalities
    @pagy = pagy
    @filtered_state = filtered_state
  end

  def view_template(&)
    div(class: "scaffold municipalities-index", id: "index_municipalities") do
      div do
        h1 do
          if @filtered_state
            "Municipalities in #{@filtered_state.name}"
          else
            "Municipalities"
          end
        end

        if @filtered_state
          div(class: "filter-info") do
            span { "Showing municipalities in " }
            link_to @filtered_state.name, @filtered_state, class: "link state"
            span { " - " }
            link_to "View all municipalities", municipalities_path, class: "link view-all"
          end
        end

        scaffold_new_resource_link "New municipality", new_municipality_path, record: Municipality
      end

      div(id: "municipalities") do
        if @municipalities.any?
          @municipalities.each do |municipality|
            div(id: dom_id(municipality, :list_item)) do
              MunicipalityPartial(municipality: municipality)

              Ui::ResourceActions(resource: municipality)
            end
          end
        else
          p { "No municipalities found." }
        end
      end

      Views::Components::Pagination(pagy: @pagy) if @pagy
    end
  end
end
