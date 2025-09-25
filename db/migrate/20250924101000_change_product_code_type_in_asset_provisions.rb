class ChangeProductCodeTypeInAssetProvisions < ActiveRecord::Migration[8.0]
  def up
    # Change column type from integer to string, preserving data by casting
    change_column :asset_provisions, :product_code, :string, using: 'product_code::text'

    # Optional: add index if needed for lookups
    # remove_index :asset_provisions, :product_code if index_exists?(:asset_provisions, :product_code)
    # add_index :asset_provisions, :product_code
  end

  def down
    # Convert back to integer if needed, non-numeric values will error; using NULLIF to avoid crash
    change_column :asset_provisions, :product_code, :integer, using: 'NULLIF(product_code, '')::integer'
  end
end


