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

ActiveRecord::Schema[8.0].define(version: 2025_09_19_145645) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "locations", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "site"
    t.text "description"
    t.string "location_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_categories", force: :cascade do |t|
    t.string "identifier"
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_types", force: :cascade do |t|
    t.string "identifier"
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "product_code"
    t.string "name"
    t.string "product_category"
    t.string "product_type"
    t.boolean "inventory"
    t.string "inventory_type"
    t.text "description"
    t.decimal "net_weight"
    t.decimal "gross_weight"
    t.decimal "cost"
    t.string "no_of_packs"
    t.boolean "active"
    t.boolean "consumable"
    t.jsonb "identification_details"
    t.jsonb "measurement_details"
    t.jsonb "manufacture_details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
