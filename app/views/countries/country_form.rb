class Views::Countries::CountryForm < Views::Components::Forms::Base
  def view_template
    row field(:name).text
    row field(:code).text
    row field(:description).textarea(rows: 4)
  end
end
