class Views::Voters::IndexView < Views::ApplicationView
  def initialize(voters:, pagy: nil, notice: nil)
    @voters = voters
    @pagy = pagy
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold voters-index", id: "index_voters") do
      render_notice if @notice.present?
      
      div do
        h1 { "Voters" }
        link_to "New voter", 
                new_voter_path,
                class: "primary"
      end

      div(id: "voters") do
        if @voters.any?
          @voters.each do |voter|
            div(id: dom_id(voter, :list_item)) do
              VoterPartial(voter: voter)
              
              Ui::ResourceActions(resource: voter)
            end
          end
        else
          p { "No voters found." }
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