class Views::Municipalities::MunicipalityForm < Views::Components::Forms::Base
  def view_template
    row field(:name).text
    row field(:state_id).collection_select(::State.all, text: :name, prompt: "Select a state"), label: "State"
    row field(:county_id).collection_select(::County.order(:name), text: :name, include_blank: "None"), label: "County"
  end
end
