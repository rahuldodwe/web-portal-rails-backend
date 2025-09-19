class RemoveManufacturerAndManufacturedItemFromProducts < ActiveRecord::Migration[8.0]
  def change
    remove_column :products, :manufacturer, :string
    remove_column :products, :manufactured_item, :string
  end
end
