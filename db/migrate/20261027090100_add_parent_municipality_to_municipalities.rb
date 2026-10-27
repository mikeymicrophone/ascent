# A town can sit inside another, as Brooklyn does inside New York City; its jurisdiction then nests
# under that town's rather than its county's.
class AddParentMunicipalityToMunicipalities < ActiveRecord::Migration[8.1]
  def change
    add_reference :municipalities, :parent_municipality, foreign_key: { to_table: :municipalities }
  end
end
