class Views::OfficialCodes::IndexView < Views::ApplicationView
  def initialize(official_codes:, pagy: nil, notice: nil)
    @official_codes = official_codes
    @pagy = pagy
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold official_codes-index", id: "index_official_codes") do
      render_notice if @notice.present?
      
      div do
        h1 { "Official codes" }
        link_to "New official code", 
                new_official_code_path,
                class: "primary"
      end

      div(id: "official_codes") do
        if @official_codes.any?
          @official_codes.each do |official_code|
            div(id: dom_id(official_code, :list_item)) do
              Views::OfficialCodes::OfficialCodePartial(official_code: official_code)
              
              div do
                link_to "Show", official_code,
                        class: "secondary"
                link_to "Edit", edit_official_code_path(official_code),
                        class: "secondary"
                button_to "Destroy", official_code,
                          method: :delete,
                          class: "danger",
                          data: { turbo_confirm: "Are you sure?" }
              end
            end
          end
        else
          p { "No official codes found." }
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