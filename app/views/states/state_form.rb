class Views::States::StateForm < Views::Components::Forms::Base
  def view_template
    row field(:name).text
    row field(:code).text
    row field(:country_id).collection_select(Country.all, text: :name, prompt: "Select a country"), label: "Country"
  end
end
