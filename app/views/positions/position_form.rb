class Views::Positions::PositionForm < Views::Components::Forms::Base
  def view_template
    row field(:title).text
    row field(:description).textarea(rows: 4)
    row field(:branch).select_choices(Position.branches.keys.map { |branch| [ branch.titleize, branch ] }, include_blank: "None")
    row field(:term_length_years).number
  end
end
