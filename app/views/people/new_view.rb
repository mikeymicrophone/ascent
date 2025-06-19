class Views::People::NewView < Views::ApplicationView
  def initialize(person:)
    @person = person
  end

  def view_template(&)
    div(class: "scaffold person-new", id: dom_id(@person, :new)) do
      h1 { "New person" }
      
      Views::People::PersonForm(person: @person)
      
      div do
        link_to "Back to people", 
                people_path,
                class: "secondary"
      end
    end
  end
end