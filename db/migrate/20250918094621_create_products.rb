class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :product_code
      t.string :name
      t.string :product_category
      t.string :product_type
      t.string :manufacturer
      t.string :manufactured_item
      t.boolean :inventory
      t.string :inventory_type
      t.text :description
      t.decimal :net_weight
      t.decimal :gross_weight
      t.decimal :cost
      t.string :no_of_packs
      t.boolean :active
      t.boolean :consumable
      t.jsonb :identification_details
      t.jsonb :measurement_details
      t.jsonb :manufacture_details

      t.timestamps
    end
  end
end
