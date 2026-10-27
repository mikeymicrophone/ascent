# frozen_string_literal: true

class CreateRuleSourceLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :rule_source_links do |t|
      t.references :linkable, polymorphic: true, null: false
      t.bigint :lu_unit_id, null: false
      t.integer :relationship_kind, null: false, default: 0
      t.text :notes

      t.timestamps
    end

    add_index :rule_source_links, :lu_unit_id
  end
end
