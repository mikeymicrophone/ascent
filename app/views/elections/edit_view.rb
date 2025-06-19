class Views::Elections::EditView < Views::ApplicationView
  def initialize(election:)
    @election = election
  end

  def view_template(&)
    div(class: "scaffold election-edit", id: dom_id(@election, :edit)) do
      h1 { "Editing election" }
      
      Views::Elections::ElectionForm(election: @election)
      
      div do
        link_to "Show this election", 
                @election,
                class: "secondary"
        link_to "Back to elections", 
                elections_path,
                class: "secondary"
      end
    end
  end
end