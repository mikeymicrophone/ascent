class Views::Voters::EditView < Views::ApplicationView
  def initialize(voter:)
    @voter = voter
  end

  def view_template(&)
    div(class: "scaffold voter-edit", id: dom_id(@voter, :edit)) do
      h1 { "Editing voter" }
      
      Views::Voters::VoterForm(voter: @voter)
      
      div do
        link_to "Show this voter", 
                @voter,
                class: "secondary"
        link_to "Back to voters", 
                voters_path,
                class: "secondary"
      end
    end
  end
end