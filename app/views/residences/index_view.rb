class Views::Residences::IndexView < Views::ApplicationView
  def initialize(residences:, pagy: nil, notice: nil)
    @residences = residences
    @pagy = pagy
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold residences-index", id: "index_residences") do
      render_notice if @notice.present?
      
      div do
        h1 { "Residences" }
        link_to "New residence", 
                new_residence_path,
                class: "primary"
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

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end