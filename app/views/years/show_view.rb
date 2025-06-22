class Views::Years::ShowView < Views::ApplicationView
  def initialize(year:, notice: nil)
    @year = year
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold year-show", id: dom_id(@year, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing year" }
      
      YearPartial(year: @year)
      
      div do
        link_to "Edit this year", 
                edit_year_path(@year),
                class: "secondary"
        link_to "Back to years", 
                years_path,
                class: "secondary"
        button_to "Destroy this year", 
                  @year,
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