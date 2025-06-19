class Views::Elections::IndexView < Views::ApplicationView
  def initialize(elections:, notice: nil)
    @elections = elections
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
              Views::Elections::ElectionPartial(election: election)
              
              div do
                link_to "Show", election,
                        class: "secondary"
                link_to "Edit", edit_election_path(election),
                        class: "secondary"
                button_to "Destroy", election,
                          method: :delete,
                          class: "danger",
                          data: { turbo_confirm: "Are you sure?" }
              end
            end
          end
        else
          p { "No elections found." }
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