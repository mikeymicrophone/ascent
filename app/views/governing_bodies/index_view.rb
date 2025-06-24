class Views::GoverningBodies::IndexView < Views::ApplicationView
  def initialize(governing_bodies:, pagy: nil, notice: nil)
    @governing_bodies = governing_bodies
    @pagy = pagy
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold governing_bodies-index", id: "index_governing_bodies") do
      render_notice if @notice.present?
      
      div do
        h1 { "Governing bodies" }
        link_to "New governing body", 
                new_governing_body_path,
                class: "primary"
      end

      div(id: "governing_bodies") do
        if @governing_bodies.any?
          @governing_bodies.each do |governing_body|
            div(id: dom_id(governing_body, :list_item)) do
              render GoverningBodyPartial.new(governing_body: governing_body)
              
              Ui::ResourceActions(resource: governing_body)
            end
          end
        else
          p { "No governing bodies found." }
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