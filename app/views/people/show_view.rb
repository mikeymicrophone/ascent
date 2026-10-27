class Views::People::ShowView < Views::ApplicationView
  prop :person, Person

  def view_template
    ResourceShow(record: @person) { PersonPartial(person: @person) }
  end
end
