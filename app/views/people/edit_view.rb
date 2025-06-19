class Views::People::EditView < Views::ApplicationView
  def initialize(person:)
    @person = person
  end

  def view_template(&)
    div(class: "scaffold person-edit", id: dom_id(@person, :edit)) do
      h1 { "Editing person" }
      
      Views::People::PersonForm(person: @person)
      
      div do
        link_to "Show this person", 
                @person,
                class: "secondary"
        link_to "Back to people", 
                people_path,
                class: "secondary"
      end
    end
  end
end