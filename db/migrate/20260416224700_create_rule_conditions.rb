# frozen_string_literal: true

class CreateRuleConditions < ActiveRecord::Migration[8.0]
  def change
    create_table :rule_conditions do |t|
      t.references :statement, null: false, foreign_key: { to_table: :rule_statements }
      t.string :slug, null: false
      t.string :label, null: false
      t.integer :kind, null: false, default: 0
      t.integer :position, null: false, default: 0
      t.text :notes

      t.timestamps
    end

    add_index :rule_conditions, [:statement_id, :slug], unique: true
  end
end
