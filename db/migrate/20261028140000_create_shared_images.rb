class CreateSharedImages < ActiveRecord::Migration[8.1]
  def up
    create_table :images do |t|
      t.string :entity_code
      t.string :url, null: false
      t.string :alt_text
      t.string :credit
      t.string :source_url
      t.timestamps
    end
    add_index :images, :entity_code, unique: true
    add_index :images, :url, unique: true

    create_table :image_placements do |t|
      t.string :entity_code
      t.references :image, null: false, foreign_key: true
      t.references :subject, polymorphic: true, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :image_placements, :entity_code, unique: true
    add_index :image_placements, %i[subject_type subject_id image_id], unique: true
    add_check_constraint :image_placements, "position >= 0", name: "image_placements_position_nonnegative"

    execute <<~SQL
      INSERT INTO images (url, credit, source_url, created_at, updated_at)
      SELECT DISTINCT ON (portrait_url) portrait_url, portrait_credit, portrait_source_url, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM people WHERE portrait_url IS NOT NULL AND portrait_url <> ''
      ORDER BY portrait_url, id;

      INSERT INTO image_placements (image_id, subject_type, subject_id, position, created_at, updated_at)
      SELECT images.id, 'Person', people.id, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM people JOIN images ON images.url = people.portrait_url;
    SQL
    remove_columns :people, :portrait_url, :portrait_credit, :portrait_source_url, type: :string
  end

  def down
    add_column :people, :portrait_url, :string
    add_column :people, :portrait_credit, :string
    add_column :people, :portrait_source_url, :string
    execute <<~SQL
      UPDATE people SET portrait_url = first_images.url, portrait_credit = first_images.credit, portrait_source_url = first_images.source_url
      FROM (
        SELECT DISTINCT ON (subject_id) subject_id, images.url, images.credit, images.source_url
        FROM image_placements JOIN images ON images.id = image_placements.image_id
        WHERE subject_type = 'Person'
        ORDER BY subject_id, position, image_placements.id
      ) first_images WHERE people.id = first_images.subject_id;
    SQL
    drop_table :image_placements
    drop_table :images
  end
end
