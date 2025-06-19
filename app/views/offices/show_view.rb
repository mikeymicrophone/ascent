class Views::Offices::ShowView < Views::ApplicationView
  def initialize(office:, notice: nil)
    @office = office
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold office-show", id: dom_id(@office, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing office" }
      
      Views::Offices::OfficePartial(office: @office)
      
      div do
        link_to "Edit this office", 
                edit_office_path(@office),
                class: "secondary"
        link_to "Back to offices", 
                offices_path,
                class: "secondary"
        button_to "Destroy this office", 
                  @office,
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