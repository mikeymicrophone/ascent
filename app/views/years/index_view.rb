class Views::Years::IndexView < Views::ApplicationView
  def initialize(years:, notice: nil)
    @years = years
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold years-index", id: "index_years") do
      render_notice if @notice.present?
      
      div do
        h1 { "Years" }
        link_to "New year", 
                new_year_path,
                class: "primary"
      end

      div(id: "years") do
        if @years.any?
          @years.each do |year|
            div(id: dom_id(year, :list_item)) do
              Views::Years::YearPartial(year: year)
              
              div do
                link_to "Show", year,
                        class: "secondary"
                link_to "Edit", edit_year_path(year),
                        class: "secondary"
                button_to "Destroy", year,
                          method: :delete,
                          class: "danger",
                          data: { turbo_confirm: "Are you sure?" }
              end
            end
          end
        else
          p { "No years found." }
        end
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