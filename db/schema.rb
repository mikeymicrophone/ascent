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

ActiveRecord::Schema[8.0].define(version: 2025_06_21_183655) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "area_of_concerns", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "policy_domain"
    t.string "regulatory_scope"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "candidacies", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.bigint "election_id", null: false
    t.string "status"
    t.date "announcement_date"
    t.string "party_affiliation"
    t.text "platform_summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["election_id"], name: "index_candidacies_on_election_id"
    t.index ["person_id"], name: "index_candidacies_on_person_id"
  end

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

  create_table "governance_types", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "authority_level"
    t.string "decision_making_process"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "people", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "middle_name"
    t.string "email"
    t.date "birth_date"
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "positions", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.boolean "is_executive"
    t.integer "term_length_years"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rating_archives", force: :cascade do |t|
    t.bigint "voter_id", null: false
    t.bigint "candidacy_id", null: false
    t.integer "rating"
    t.datetime "archived_at"
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["candidacy_id"], name: "index_rating_archives_on_candidacy_id"
    t.index ["voter_id"], name: "index_rating_archives_on_voter_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.bigint "voter_id", null: false
    t.bigint "candidacy_id", null: false
    t.integer "rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["candidacy_id"], name: "index_ratings_on_candidacy_id"
    t.index ["voter_id"], name: "index_ratings_on_voter_id"
  end

  create_table "residences", force: :cascade do |t|
    t.bigint "voter_id", null: false
    t.string "jurisdiction_type", null: false
    t.bigint "jurisdiction_id", null: false
    t.datetime "registered_at"
    t.string "status"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jurisdiction_type", "jurisdiction_id"], name: "index_residences_on_jurisdiction"
    t.index ["voter_id"], name: "index_residences_on_voter_id"
  end

  create_table "states", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.bigint "country_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_states_on_country_id"
  end

  create_table "voter_election_baseline_archives", force: :cascade do |t|
    t.bigint "voter_id", null: false
    t.bigint "election_id", null: false
    t.integer "baseline", null: false
    t.datetime "archived_at", null: false
    t.string "reason", null: false
    t.integer "previous_baseline"
    t.integer "new_baseline"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["archived_at"], name: "index_voter_election_baseline_archives_on_archived_at"
    t.index ["election_id"], name: "index_voter_election_baseline_archives_on_election_id"
    t.index ["voter_id", "election_id"], name: "index_baseline_archives_on_voter_and_election"
    t.index ["voter_id"], name: "index_voter_election_baseline_archives_on_voter_id"
  end

  create_table "voter_election_baselines", force: :cascade do |t|
    t.bigint "voter_id", null: false
    t.bigint "election_id", null: false
    t.integer "baseline"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["election_id"], name: "index_voter_election_baselines_on_election_id"
    t.index ["voter_id"], name: "index_voter_election_baselines_on_voter_id"
  end

  create_table "voters", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "first_name"
    t.string "last_name"
    t.date "birth_date"
    t.boolean "is_verified"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_voters_on_email", unique: true
    t.index ["reset_password_token"], name: "index_voters_on_reset_password_token", unique: true
  end

  create_table "years", force: :cascade do |t|
    t.integer "year"
    t.boolean "is_even_year"
    t.boolean "is_presidential_year"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "candidacies", "elections"
  add_foreign_key "candidacies", "people"
  add_foreign_key "cities", "states"
  add_foreign_key "elections", "offices"
  add_foreign_key "elections", "years"
  add_foreign_key "offices", "positions"
  add_foreign_key "rating_archives", "candidacies"
  add_foreign_key "rating_archives", "voters"
  add_foreign_key "ratings", "candidacies"
  add_foreign_key "ratings", "voters"
  add_foreign_key "residences", "voters"
  add_foreign_key "states", "countries"
  add_foreign_key "voter_election_baseline_archives", "elections"
  add_foreign_key "voter_election_baseline_archives", "voters"
  add_foreign_key "voter_election_baselines", "elections"
  add_foreign_key "voter_election_baselines", "voters"
end
