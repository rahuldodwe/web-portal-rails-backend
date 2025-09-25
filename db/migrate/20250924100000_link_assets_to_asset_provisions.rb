class LinkAssetsToAssetProvisions < ActiveRecord::Migration[8.0]
  def up
    add_reference :assets, :asset_provision, foreign_key: true
    add_column :assets, :qty, :integer

    say_with_time "Backfilling assets from asset_provisions.product_items" do
      AssetProvision.reset_column_information
      Asset.reset_column_information

      AssetProvision.find_each do |ap|
        items = ap.read_attribute(:product_items) || []
        items.each do |item|
          uid = item.is_a?(Hash) ? (item['uid'] || item[:uid]) : nil
          qty = item.is_a?(Hash) ? (item['qty'] || item[:qty]) : nil
          status = item.is_a?(Hash) ? (item['status'] || item[:status]) : nil

          next if uid.blank?

          asset = Asset.find_or_initialize_by(uid: uid)
          asset.asset_provision_id = ap.id
          asset.qty = qty if qty.present?
          asset.status = status if status.present?
          # Optionally carry over product_code/site/location if available on AP
          asset.product_code ||= ap.product_code&.to_s
          asset.site ||= ap.site
          asset.location ||= ap.location
          asset.save!
        end
      end
    end
  end

  def down
    remove_column :assets, :qty, :integer if column_exists?(:assets, :qty)
    if foreign_key_exists?(:assets, :asset_provisions)
      remove_foreign_key :assets, :asset_provisions
    end
    remove_column :assets, :asset_provision_id if column_exists?(:assets, :asset_provision_id)
  end
end


