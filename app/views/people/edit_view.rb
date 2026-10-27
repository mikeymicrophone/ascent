class Views::People::EditView < Views::ApplicationView
  prop :person, Person

  def view_template
    ResourceFormPage(record: @person) { render Views::People::PersonForm.new(@person) }
  end
end
