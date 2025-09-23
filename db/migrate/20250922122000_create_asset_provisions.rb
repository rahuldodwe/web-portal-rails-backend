class CreateAssetProvisions < ActiveRecord::Migration[8.0]
  def change
    create_table :asset_provisions do |t|
      t.integer :product_code
      t.string :site
      t.string :location
      t.string :location_type
      t.integer :quantity
      t.jsonb :product_items, default: []

      t.timestamps
    end

    add_index :asset_provisions, :product_code
    add_index :asset_provisions, :site
  end
end





