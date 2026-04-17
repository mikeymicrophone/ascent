# frozen_string_literal: true

class CreateRuleTopics < ActiveRecord::Migration[8.0]
  def change
    create_table :rule_topics do |t|
      t.string :slug, null: false
      t.string :title, null: false
      t.text :description
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :rule_topics, :slug, unique: true
  end
end
