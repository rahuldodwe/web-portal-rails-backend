class AddExtendedFieldsToAssets < ActiveRecord::Migration[8.0]
  def change
    add_column :assets, :primary_identifier, :string
    add_column :assets, :location_move_time, :datetime
    add_column :assets, :previous_location, :string
    add_column :assets, :asset_status, :string
    add_column :assets, :item_revision, :integer
    add_column :assets, :condition, :string
    add_column :assets, :quantity, :integer

    add_column :assets, :identifiers, :jsonb
    add_column :assets, :physical_attribute, :jsonb
    add_column :assets, :lifecycle, :jsonb
    add_column :assets, :history, :jsonb
    add_column :assets, :comment, :jsonb

    add_index :assets, :primary_identifier
    add_index :assets, :asset_status
  end
end