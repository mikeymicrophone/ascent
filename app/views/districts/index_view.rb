class Views::Districts::IndexView < Views::ApplicationView
  def initialize(districts:, pagy: nil, notice: nil)
    @districts = districts
    @pagy = pagy
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold districts-index", id: "index_districts") do
      render_notice if @notice.present?
      
      div do
        h1 { "Districts" }
        scaffold_new_resource_link "New district", new_district_path, record: District
      end

      div(id: "districts") do
        if @districts.any?
          @districts.each do |district|
            div(id: dom_id(district, :list_item)) do
              DistrictPartial(district: district)
              
              Ui::ResourceActions(resource: district)
            end
          end
        else
          p { "No districts found." }
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
