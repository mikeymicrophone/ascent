class Views::Years::YearForm < Views::Components::Forms::Base
  def view_template
    row field(:year).number
    row field(:is_even_year).checkbox
    row field(:is_presidential_year).checkbox
    row field(:description).textarea(rows: 4)
  end
end
