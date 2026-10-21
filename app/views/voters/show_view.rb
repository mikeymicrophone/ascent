class Views::Voters::ShowView < Views::ApplicationView
  def initialize(voter:)
    @voter = voter
  end

  def view_template(&)
    div(class: "scaffold voter-show", id: dom_id(@voter, :show)) do
      h1 { "Showing voter" }

      VoterPartial(voter: @voter)

      Ui::ResourceActions(resource: @voter)
    end
  end
end
