class Views::Elections::IndexView < Views::ApplicationView
  def initialize(elections:, pagy: nil, notice: nil)
    @elections = elections
    @pagy = pagy
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold elections-index", id: "index_elections") do
      render_notice if @notice.present?
      
      div do
        h1 { "Elections" }
        link_to "New election", 
                new_election_path,
                class: "primary"
      end

      div(id: "elections") do
        if @elections.any?
          @elections.each do |election|
            div(id: dom_id(election, :list_item)) do
              ElectionPartial(election: election)
              
              div do
                button_to("Simulate Data", simulate_mountain_path(election), 
                  method: :post, class: "btn-secondary", form: { style: "display: inline;" })
                whitespace
                Ui::ResourceActions(resource: election)
              end
            end
          end
        else
          p { "No elections found." }
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