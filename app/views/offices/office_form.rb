class Views::Offices::OfficeForm < Views::Components::Forms::Base
  def view_template
    row field(:position_id).collection_select(::Position.all, text: :title, prompt: "Select a position"), label: "Position"
    row field(:jurisdiction_id).select_choices(jurisdiction_choices, prompt: "Select a jurisdiction"), label: "Jurisdiction"
    row field(:governing_body_id).collection_select(::GoverningBody.order(:name), text: :name, include_blank: "None"), label: "Governing body"
    row field(:chamber_id).collection_select(::Chamber.order(:name), text: :name, include_blank: "None"), label: "Chamber"
    row field(:is_active).checkbox
    row field(:notes).textarea(rows: 4)
  end
end
