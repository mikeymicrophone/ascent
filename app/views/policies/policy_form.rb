class Views::Policies::PolicyForm < Views::Components::Forms::Base
  def view_template
    row field(:governing_body_id).collection_select(::GoverningBody.all, text: :name, prompt: "Select a governing body"), label: "Governing body"
    row field(:area_of_concern_id).collection_select(::AreaOfConcern.all, text: :name, prompt: "Select an area of concern"), label: "Area of concern"
    row field(:approach_id).collection_select(::Approach.all, text: :name, prompt: "Select an approach"), label: "Approach"
    row field(:title).text
    row field(:description).textarea(rows: 4)
    row field(:status).select_choices(Policy.statuses.keys.map { |status| [ status.capitalize, status ] })
    row field(:enacted_date).date
    row field(:expiration_date).date
  end
end
