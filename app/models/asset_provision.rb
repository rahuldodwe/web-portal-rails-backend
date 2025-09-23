class AssetProvision < ApplicationRecord
  def as_json(options = {})
    base = super(options)
    normalized_items = (product_items || []).map do |i|
      {
        'id' => i['id'] || i[:id],
        'uid' => i['uid'] || i[:uid],
        'qty' => i['qty'] || i[:qty],
        'status' => i['status'] || i[:status]
      }
    end

    base.merge(
      'productCode' => base.delete('product_code'),
      'locationType' => base.delete('location_type'),
      'quantity' => base['quantity'],
      'productItems' => normalized_items,
      'dateCreated' => base.delete('created_at'),
      'lastUpdated' => base.delete('updated_at')
    )
  end
end





