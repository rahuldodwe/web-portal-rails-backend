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

# Seed Asset Provisions
[
  {
    productCode: 1001,
    site: "HQ",
    location: "Dock-01",
    locationType: "Dock Door",
    quantity: 3,
    productItems: [
      { id: 1, uid: 10001, qty: 1, status: "Allocated" },
      { id: 2, uid: 10002, qty: 1, status: "Allocated" },
      { id: 3, uid: 10003, qty: 1, status: "Pending" }
    ]
  },
  {
    productCode: 1002,
    site: "HQ",
    location: "Rack-A1",
    locationType: "Rack",
    quantity: 2,
    productItems: [
      { id: 1, uid: 20001, qty: 1, status: "Allocated" },
      { id: 2, uid: 20002, qty: 1, status: "Allocated" }
    ]
  }
].each do |attrs|
  AssetProvision.find_or_create_by!(product_code: attrs[:productCode], location: attrs[:location]) do |ap|
    ap.product_code = attrs[:productCode]
    ap.site = attrs[:site]
    ap.location = attrs[:location]
    ap.location_type = attrs[:locationType]
    ap.quantity = attrs[:quantity]
    ap.product_items = attrs[:productItems].map { |i| { "id" => i[:id], "uid" => i[:uid], "qty" => i[:qty], "status" => i[:status] } }
  end
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

# Seed 11 Assets
statuses = ["Active", "Inactive", "Under Maintenance"]
asset_types = ["Equipment", "Container", "Tool"]
owner_names = ["Logistics", "Operations", "Quality", "Warehouse"]

(1..11).each do |i|
  uid = format("ASSET-%03d", i)
  Asset.find_or_create_by!(uid: uid) do |a|
    a.product_code = "P-1001"
    a.manufacturer = "Acme Industries"
    a.batch_no = format("BATCH-%04d", 1000 + i)
    a.site = "HQ"
    a.description = "Seeded asset #{uid}"
    a.asset_type = asset_types[i % asset_types.length]
    a.status = statuses[i % statuses.length]
    a.location = "LOC-001"
    a.owner = owner_names[i % owner_names.length]
    a.assignee = ["Alice", "Bob", "Charlie", "Dana"][i % 4]
    a.last_validation_date = Date.today - i
    a.last_move_date = Date.today - (i * 2)
    a.last_physical_inventory_date = Date.today - (i * 3)
  end
end


# Seed EdgeDevices
[
  {
    code: 1001,
    name: "Edge-Alpha",
    description: "Primary gateway device",
    registered: true,
    status: true,
    serial: {
      "baudRate" => 9600,
      "dataBits" => 8,
      "stopBits" => 1,
      "parity" => "None"
    },
    tcp: {
      "ipAddress" => "192.168.1.10",
      "tcpPort" => 502
    },
    static: {
      "latitude" => 37.7749,
      "longitude" => -122.4194
    }
  },
  {
    code: 1002,
    name: "Edge-Beta",
    description: "Backup gateway device",
    registered: true,
    status: false,
    serial: {
      "baudRate" => 19200,
      "dataBits" => 7,
      "stopBits" => 1,
      "parity" => "Even"
    },
    tcp: {
      "ipAddress" => "192.168.1.11",
      "tcpPort" => 503
    },
    static: {
      "latitude" => 34.0522,
      "longitude" => -118.2437
    }
  },
  {
    code: 1003,
    name: "Edge-Gamma",
    description: "Test edge device",
    registered: false,
    status: false,
    serial: {
      "baudRate" => 57600,
      "dataBits" => 8,
      "stopBits" => 2,
      "parity" => "Odd"
    },
    tcp: {
      "ipAddress" => "10.0.0.5",
      "tcpPort" => 1502
    },
    static: {
      "latitude" => 40.7128,
      "longitude" => -74.0060
    }
  },
  {
    code: 1004,
    name: "Edge-Delta",
    description: "Warehouse floor controller",
    registered: true,
    status: true,
    serial: {
      "baudRate" => 115200,
      "dataBits" => 8,
      "stopBits" => 1,
      "parity" => "None"
    },
    tcp: {
      "ipAddress" => "172.16.0.20",
      "tcpPort" => 502
    },
    static: {
      "latitude" => 51.5074,
      "longitude" => -0.1278
    }
  },
  {
    code: 1005,
    name: "Edge-Epsilon",
    description: "Outdoor telemetry collector",
    registered: false,
    status: true,
    serial: {
      "baudRate" => 38400,
      "dataBits" => 8,
      "stopBits" => 1,
      "parity" => "None"
    },
    tcp: {
      "ipAddress" => "10.10.10.50",
      "tcpPort" => 2502
    },
    static: {
      "latitude" => 48.8566,
      "longitude" => 2.3522
    }
  }
].each do |attrs|
  EdgeDevice.find_or_create_by!(code: attrs[:code]) do |d|
    d.name = attrs[:name]
    d.description = attrs[:description]
    d.registered = attrs[:registered]
    d.status = attrs[:status]
    d.serial = attrs[:serial]
    d.tcp = attrs[:tcp]
    d.static = attrs[:static]
  end
end


# Seed Passive RFIDs
[
  {
    name: "RFID-Reader-A",
    hostName: "reader-a.local",
    port: 5084,
    manufacturer: "Impinj",
    model: "R700",
    description: "Dock door reader",
    antennaCount: 2,
    antennas: [
      { antenna: 1, rxSensitivity: -70, txPower: 25, enabled: true },
      { antenna: 2, rxSensitivity: -65, txPower: 27, enabled: true }
    ],
    gpiConfig: 2,
    gpoConfig: 2,
    enabled: true,
    edgeDevice: "Edge-Alpha"
  },
  {
    name: "RFID-Reader-B",
    hostName: "reader-b.local",
    port: 5084,
    manufacturer: "Zebra",
    model: "FX9600",
    description: "Staging area reader",
    antennaCount: 4,
    antennas: [
      { antenna: 1, rxSensitivity: -60, txPower: 29, enabled: true },
      { antenna: 2, rxSensitivity: -62, txPower: 28, enabled: true },
      { antenna: 3, rxSensitivity: -64, txPower: 27, enabled: false },
      { antenna: 4, rxSensitivity: -66, txPower: 26, enabled: false }
    ],
    gpiConfig: 0,
    gpoConfig: 0,
    enabled: false,
    edgeDevice: "Edge-Beta"
  }
].each do |attrs|
  PassiveRfid.find_or_create_by!(name: attrs[:name]) do |r|
    r.host_name = attrs[:hostName]
    r.port = attrs[:port]
    r.manufacturer = attrs[:manufacturer]
    r.model = attrs[:model]
    r.description = attrs[:description]
    r.antenna_count = attrs[:antennaCount]
    r.antennas = attrs[:antennas].map { |a| { "antenna" => a[:antenna], "rxSensitivity" => a[:rxSensitivity], "txPower" => a[:txPower], "enabled" => a[:enabled] } }
    r.gpi_config = attrs[:gpiConfig]
    r.gpo_config = attrs[:gpoConfig]
    r.enabled = attrs[:enabled]
    r.edge_device = attrs[:edgeDevice]
  end
end

