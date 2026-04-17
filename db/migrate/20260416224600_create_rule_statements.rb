# frozen_string_literal: true

class CreateRuleStatements < ActiveRecord::Migration[8.0]
  def change
    create_table :rule_statements do |t|
      t.references :topic, null: false, foreign_key: { to_table: :rule_topics }
      t.string :slug, null: false
      t.string :title, null: false
      t.integer :effect, null: false, default: 0
      t.string :actor_label
      t.string :action_label
      t.string :object_label
      t.text :summary, null: false
      t.integer :position, null: false, default: 0
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :rule_statements, [:topic_id, :slug], unique: true
  end
end
