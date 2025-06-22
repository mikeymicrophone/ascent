class Views::GovernanceTypes::IndexView < Views::ApplicationView
  def initialize(governance_types:, pagy: nil, notice: nil)
    @governance_types = governance_types
    @pagy = pagy
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold governance_types-index", id: "index_governance_types") do
      render_notice if @notice.present?
      
      div do
        h1 { "Governance types" }
        link_to "New governance type", 
                new_governance_type_path,
                class: "primary"
      end

      div(id: "governance_types") do
        if @governance_types.any?
          @governance_types.each do |governance_type|
            div(id: dom_id(governance_type, :list_item)) do
              GovernanceTypePartial(governance_type: governance_type)
              
              div do
                link_to "Show", governance_type,
                        class: "secondary"
                link_to "Edit", edit_governance_type_path(governance_type),
                        class: "secondary"
                button_to "Destroy", governance_type,
                          method: :delete,
                          class: "danger",
                          data: { turbo_confirm: "Are you sure?" }
              end
            end
          end
        else
          p { "No governance types found." }
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