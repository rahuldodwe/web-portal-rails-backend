class CreatePassiveRfids < ActiveRecord::Migration[8.0]
  def change
    create_table :passive_rfids do |t|
      t.string :name
      t.string :host_name
      t.integer :port
      t.string :manufacturer
      t.string :model
      t.text :description
      t.integer :antenna_count
      t.jsonb :antennas, default: []
      t.integer :gpi_config
      t.integer :gpo_config
      t.boolean :enabled
      t.string :edge_device

      t.timestamps
    end

    add_index :passive_rfids, :name
    add_index :passive_rfids, :edge_device
  end
end


