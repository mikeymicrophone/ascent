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
        scaffold_new_resource_link "New election", new_election_path, record: Election
      end

      div(id: "elections") do
        if @elections.any?
          @elections.each do |election|
            div(id: dom_id(election, :list_item)) do
              ElectionPartial(election: election)
              
              Ui::ResourceActions(resource: election)
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
