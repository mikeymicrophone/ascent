class Views::People::ShowView < Views::ApplicationView
  def initialize(person:)
    @person = person
  end

  def view_template(&)
    div(class: "scaffold person-show", id: dom_id(@person, :show)) do
      h1 { "Showing person" }

      PersonPartial(person: @person)

      Ui::ResourceActions(resource: @person)
    end
  end
end
