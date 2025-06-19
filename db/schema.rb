# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_19_212147) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.bigint "state_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["state_id"], name: "index_cities_on_state_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "elections", force: :cascade do |t|
    t.bigint "office_id", null: false
    t.bigint "year_id", null: false
    t.date "election_date"
    t.string "status"
    t.text "description"
    t.boolean "is_mock"
    t.boolean "is_historical"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["office_id"], name: "index_elections_on_office_id"
    t.index ["year_id"], name: "index_elections_on_year_id"
  end

  create_table "offices", force: :cascade do |t|
    t.bigint "position_id", null: false
    t.string "jurisdiction_type", null: false
    t.bigint "jurisdiction_id", null: false
    t.boolean "is_active"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jurisdiction_type", "jurisdiction_id"], name: "index_offices_on_jurisdiction"
    t.index ["position_id"], name: "index_offices_on_position_id"
  end

  create_table "positions", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.boolean "is_executive"
    t.integer "term_length_years"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "states", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_states_on_country_id"
  end

  create_table "years", force: :cascade do |t|
    t.integer "year"
    t.boolean "is_even_year"
    t.boolean "is_presidential_year"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "cities", "states"
  add_foreign_key "elections", "offices"
  add_foreign_key "elections", "years"
  add_foreign_key "offices", "positions"
  add_foreign_key "states", "countries"
end
