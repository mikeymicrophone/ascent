# Parties become one kind of Organization, the endorsers and nominators of candidacies, and an
# Office can be a nomination: the place on a general ballot that a primary decides.
class CreateOrganizationsAndNominations < ActiveRecord::Migration[8.1]
  def up
    rename_table :parties, :organizations
    # Rails leaves the type of a base-class record blank, so a plain organization defaults to its own.
    add_column :organizations, :type, :string, null: false, default: "Organization"
    add_column :organizations, :kind, :string
    execute "UPDATE organizations SET type = 'Party'"
    change_column_null :organizations, :state_id, true
    add_check_constraint :organizations, "type <> 'Party' OR state_id IS NOT NULL", name: "parties_have_a_state"

    # Polymorphic references store the base class, which is now Organization.
    execute "UPDATE endorsements SET endorser_type = 'Organization' WHERE endorser_type = 'Party'"
    execute "UPDATE channels SET owner_type = 'Organization' WHERE owner_type = 'Party'"
    execute "UPDATE entity_codes SET record_type = 'Organization' WHERE record_type = 'Party'"

    add_reference :offices, :nominee_for_office, foreign_key: { to_table: :offices }
    add_reference :offices, :nominating_organization, foreign_key: { to_table: :organizations }
    add_column :offices, :nominee_count, :integer
    add_check_constraint :offices,
      "(nominee_for_office_id IS NULL) = (nominating_organization_id IS NULL) AND (nominee_for_office_id IS NULL) = (nominee_count IS NULL)",
      name: "nominations_name_their_office_organization_and_count"
  end

  def down
    remove_check_constraint :offices, name: "nominations_name_their_office_organization_and_count"
    remove_column :offices, :nominee_count
    remove_reference :offices, :nominating_organization, foreign_key: { to_table: :organizations }
    remove_reference :offices, :nominee_for_office, foreign_key: { to_table: :offices }

    execute "UPDATE entity_codes SET record_type = 'Party' WHERE record_type = 'Organization'"
    execute "UPDATE channels SET owner_type = 'Party' WHERE owner_type = 'Organization'"
    execute "UPDATE endorsements SET endorser_type = 'Party' WHERE endorser_type = 'Organization'"

    remove_check_constraint :organizations, name: "parties_have_a_state"
    execute "DELETE FROM organizations WHERE type <> 'Party'"
    change_column_null :organizations, :state_id, false
    remove_column :organizations, :kind
    remove_column :organizations, :type
    rename_table :organizations, :parties
  end
end
