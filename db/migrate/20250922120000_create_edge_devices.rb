class CreateEdgeDevices < ActiveRecord::Migration[8.0]
  def change
    create_table :edge_devices do |t|
      t.integer :code
      t.string :name
      t.text :description
      t.boolean :registered
      t.boolean :status

      # structured fields
      t.jsonb :serial
      t.jsonb :tcp
      t.jsonb :static

      t.timestamps
    end

    add_index :edge_devices, :code, unique: true
  end
end



