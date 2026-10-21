class Views::Stances::IndexView < Views::ApplicationView
  def initialize(stances:, pagy: nil)
    @stances = stances
    @pagy = pagy
  end

  def view_template(&)
    div(class: "scaffold stances-index", id: "index_stances") do
      div do
        h1 { "Stances" }
        scaffold_new_resource_link "New stance", new_stance_path, record: Stance
      end

      div(id: "stances") do
        if @stances.any?
          @stances.each do |stance|
            div(id: dom_id(stance, :list_item)) do
              StancePartial(stance: stance)

              Ui::ResourceActions(resource: stance)
            end
          end
        else
          p { "No stances found." }
        end
      end

      Views::Components::Pagination(pagy: @pagy) if @pagy
    end
  end
end
