# A general's off-ballot candidacy for someone who ran in a primary for its nomination points
# back at that primary candidacy, so a simulated approval vote can rate everyone who ran.
class AddPrimaryCandidacyToCandidacies < ActiveRecord::Migration[8.1]
  def change
    add_reference :candidacies, :primary_candidacy, foreign_key: { to_table: :candidacies }
    add_index :candidacies, [ :race_id, :person_id ], unique: true, where: "primary_candidacy_id IS NOT NULL", name: "index_candidacies_from_primaries_once_per_race_and_person"
  end
end
