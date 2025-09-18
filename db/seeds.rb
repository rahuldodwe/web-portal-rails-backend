# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

product_category = ProductCategory.find_or_create_by!(identifier: "CAT-001") do |pc|
  pc.name = "Beverages"
  pc.description = "Drinkable items"
end

Location.find_or_create_by!(code: "LOC-001") do |l|
  l.name = "Main Warehouse"
  l.site = "HQ"
  l.description = "Primary storage facility"
  l.location_type = "Warehouse"
end
product_type = ProductType.find_or_create_by!(identifier: "TYPE-001") do |pt|
  pt.name = "Soft Drink"
  pt.description = "Carbonated beverage"
end

Product.find_or_create_by!(product_code: "P-1001") do |p|
  p.name = "Cola 330ml"
  p.product_category = product_category.identifier
  p.product_type = product_type.identifier
  p.manufacturer = "Acme Beverages"
  p.manufactured_item = "COLA-330"
  p.inventory = true
  p.inventory_type = "Finished Goods"
  p.description = "Classic cola in 330ml can"
  p.net_weight = 0.33
  p.gross_weight = 0.36
  p.cost = 0.25
  p.no_of_packs = "24"
  p.active = true
  p.consumable = true
  p.identification_details = {
    identifier_type: "SKU",
    primary_identifier: "COLA-330",
    item_upc: "0123456789012",
    case_upc: "0987654321098",
    conveyance: false,
    revision: "A",
    uom: "EA"
  }
  p.measurement_details = {
    each_weight: 0.33,
    each_height: 12.0,
    each_length: 6.0,
    each_width: 6.0,
    each_cube: 0.43,
    case_weight: 8.0,
    case_cube: 10.0,
    case_quantity: 24,
    case_quantity_per_layer: 6,
    layer_qty_per_pallet: 10,
    conveyance_type: 1
  }
  p.manufacture_details = {
    manufacturer_name: "Acme Beverages",
    manufactured_item: "COLA-330",
    make: "Acme",
    model: "Standard",
    supplier_name: "Acme Supply Co",
    supplier_item: "SUP-COLA-330"
  }
end
