class Views::Elections::NewView < Views::ApplicationView
  def initialize(election:)
    @election = election
  end

  def view_template(&)
    div(class: "scaffold election-new", id: dom_id(@election, :new)) do
      h1 { "New election" }
      
      Views::Elections::ElectionForm(election: @election)
      
      div do
        link_to "Back to elections", 
                elections_path,
                class: "secondary"
      end
    end
  end
end