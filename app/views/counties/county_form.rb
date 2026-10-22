class Views::Counties::CountyForm < Views::Components::Forms::Base
  def view_template
    row field(:name).text
    row field(:state_id).collection_select(::State.all, text: :name, prompt: "Select a state"), label: "State"
    row field(:code).text
  end
end
