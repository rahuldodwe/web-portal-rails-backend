class CreateAssets < ActiveRecord::Migration[8.0]
  def change
    create_table :assets do |t|
      t.string :uid
      t.string :product_code
      t.string :manufacturer
      t.string :batch_no
      t.string :site
      t.text :description
      t.string :asset_type
      t.string :status
      t.string :location
      t.string :owner
      t.string :assignee
      t.date :last_validation_date
      t.date :last_move_date
      t.date :last_physical_inventory_date

      t.timestamps
    end
  end
end
