class Views::OfficialCodes::ShowView < Views::ApplicationView
  def initialize(official_code:, notice: nil)
    @official_code = official_code
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold official_code-show", id: dom_id(@official_code, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing official code" }
      
      OfficialCodePartial(official_code: @official_code)
      
      div do
        link_to "Edit this official code", 
                edit_official_code_path(@official_code),
                class: "secondary"
        link_to "Back to official codes", 
                official_codes_path,
                class: "secondary"
        button_to "Destroy this official code", 
                  @official_code,
                  method: :delete,
                  class: "danger",
                  data: { turbo_confirm: "Are you sure?" }
      end
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end