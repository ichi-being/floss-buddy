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

ActiveRecord::Schema[7.0].define(version: 2024_01_21_074156) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "floss_records", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "record_date"
    t.integer "consecutive_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "record_date"], name: "index_floss_records_on_user_id_and_record_date", unique: true
    t.index ["user_id"], name: "index_floss_records_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "line_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "display_name", null: false
    t.string "image"
  end

  add_foreign_key "floss_records", "users"
end
