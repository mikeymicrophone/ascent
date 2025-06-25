class Views::Years::IndexView < Views::ApplicationView
  def initialize(years:, pagy: nil, notice: nil)
    @years = years
    @pagy = pagy
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
              YearPartial(year: year)
              
              Ui::ResourceActions(resource: year)
            end
          end
        else
          p { "No years found." }
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