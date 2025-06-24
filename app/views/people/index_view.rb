class Views::People::IndexView < Views::ApplicationView
  def initialize(people:, pagy: nil, notice: nil)
    @people = people
    @pagy = pagy
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold people-index", id: "index_people") do
      render_notice if @notice.present?
      
      div do
        h1 { "People" }
        link_to "New person", 
                new_person_path,
                class: "primary"
      end

      div(id: "people") do
        if @people.any?
          @people.each do |person|
            div(id: dom_id(person, :list_item)) do
              PersonPartial(person: person)
              
              Ui::ResourceActions(resource: person)
            end
          end
        else
          p { "No people found." }
        end
      end

      Views::Components::Pagination(pagy: @pagy) if @pagy
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end