class CreateLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :locations do |t|
      t.string :code
      t.string :name
      t.string :site
      t.text :description
      t.string :location_type

      t.timestamps
    end
  end
end
