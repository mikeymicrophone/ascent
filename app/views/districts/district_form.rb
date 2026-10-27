class Views::Districts::DistrictForm < Views::Components::Forms::Base
  def view_template
    row field(:name).text
    row field(:kind).text(placeholder: "ward, legislative district, school district")
  end
end
