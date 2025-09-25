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

ActiveRecord::Schema[8.0].define(version: 2025_09_24_103000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "asset_provisions", force: :cascade do |t|
    t.string "product_code"
    t.string "site"
    t.string "location"
    t.string "location_type"
    t.integer "quantity"
    t.jsonb "product_items", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_code"], name: "index_asset_provisions_on_product_code"
    t.index ["site"], name: "index_asset_provisions_on_site"
  end

  create_table "assets", force: :cascade do |t|
    t.string "uid"
    t.string "product_code"
    t.string "manufacturer"
    t.string "batch_no"
    t.string "site"
    t.text "description"
    t.string "asset_type"
    t.string "status"
    t.string "location"
    t.string "owner"
    t.string "assignee"
    t.date "last_validation_date"
    t.date "last_move_date"
    t.date "last_physical_inventory_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "asset_provision_id"
    t.integer "qty"
    t.string "primary_identifier"
    t.datetime "location_move_time"
    t.string "previous_location"
    t.string "asset_status"
    t.integer "item_revision"
    t.string "condition"
    t.integer "quantity"
    t.jsonb "identifiers"
    t.jsonb "physical_attribute"
    t.jsonb "lifecycle"
    t.jsonb "history"
    t.jsonb "comment"
    t.index ["asset_provision_id"], name: "index_assets_on_asset_provision_id"
    t.index ["asset_status"], name: "index_assets_on_asset_status"
    t.index ["primary_identifier"], name: "index_assets_on_primary_identifier"
  end

  create_table "edge_devices", force: :cascade do |t|
    t.integer "code"
    t.string "name"
    t.text "description"
    t.boolean "registered"
    t.boolean "status"
    t.jsonb "serial"
    t.jsonb "tcp"
    t.jsonb "static"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_edge_devices_on_code", unique: true
  end

  create_table "locations", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "site"
    t.text "description"
    t.string "location_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "passive_rfids", force: :cascade do |t|
    t.string "name"
    t.string "host_name"
    t.integer "port"
    t.string "manufacturer"
    t.string "model"
    t.text "description"
    t.integer "antenna_count"
    t.jsonb "antennas", default: []
    t.integer "gpi_config"
    t.integer "gpo_config"
    t.boolean "enabled"
    t.string "edge_device"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["edge_device"], name: "index_passive_rfids_on_edge_device"
    t.index ["name"], name: "index_passive_rfids_on_name"
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

  add_foreign_key "assets", "asset_provisions"
end
