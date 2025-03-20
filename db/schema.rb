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

ActiveRecord::Schema.define(version: 2025_03_13_112731) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "person_records", force: :cascade do |t|
    t.integer "person_id"
    t.string "person_record_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "persons", force: :cascade do |t|
    t.string "fullname"
    t.string "given_name"
    t.string "family_name"
    t.string "alternate_names"
    t.string "description"
    t.integer "sex"
    t.date "date_of_birth"
    t.integer "age"
    t.string "home_street"
    t.string "home_neighborhood"
    t.string "home_city"
    t.string "home_state"
    t.integer "home_postal_code"
    t.string "home_country"
    t.string "photo_url"
    t.string "profile_urls"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "google_id"
    t.string "name"
    t.string "email"
    t.string "avatar_url"
    t.integer "person_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
