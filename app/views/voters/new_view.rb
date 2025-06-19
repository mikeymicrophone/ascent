class Views::Voters::NewView < Views::ApplicationView
  def initialize(voter:)
    @voter = voter
  end

  def view_template(&)
    div(class: "scaffold voter-new", id: dom_id(@voter, :new)) do
      h1 { "New voter" }
      
      Views::Voters::VoterForm(voter: @voter)
      
      div do
        link_to "Back to voters", 
                voters_path,
                class: "secondary"
      end
    end
  end
end