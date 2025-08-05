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

ActiveRecord::Schema[7.2].define(version: 2025_08_05_032729) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "histories", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.date "recording_date", null: false
    t.bigint "stock_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "exist_quantity"
    t.integer "num_quantity"
    t.index ["stock_id"], name: "index_histories_on_stock_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["name"], name: "index_locations_on_name", unique: true
    t.index ["user_id"], name: "index_locations_on_user_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.string "name", null: false
    t.integer "model", default: 0, null: false
    t.bigint "user_id"
    t.bigint "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_stocks_on_location_id"
    t.index ["user_id"], name: "index_stocks_on_user_id"
  end

  create_table "templetes", force: :cascade do |t|
    t.integer "group", null: false
    t.string "location_name", null: false
    t.string "stock_name", null: false
    t.integer "stock_model", default: 0, null: false
    t.integer "history_exist_quantity"
    t.integer "history_num_quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.integer "partner_id"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "histories", "stocks"
  add_foreign_key "locations", "users"
  add_foreign_key "stocks", "locations"
  add_foreign_key "stocks", "users"
end
