class Views::Offices::IndexView < Views::ApplicationView
  def initialize(offices:, pagy: nil, notice: nil)
    @offices = offices
    @pagy = pagy
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold offices-index", id: "index_offices") do
      render_notice if @notice.present?
      
      div do
        h1 { "Offices" }
        link_to "New office", 
                new_office_path,
                class: "primary"
      end

      div(id: "offices") do
        if @offices.any?
          @offices.each do |office|
            div(id: dom_id(office, :list_item)) do
              Views::Offices::OfficePartial(office: office)
              
              div do
                link_to "Show", office,
                        class: "secondary"
                link_to "Edit", edit_office_path(office),
                        class: "secondary"
                button_to "Destroy", office,
                          method: :delete,
                          class: "danger",
                          data: { turbo_confirm: "Are you sure?" }
              end
            end
          end
        else
          p { "No offices found." }
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