class Product < ApplicationRecord
  # Virtual attributes to expose manufacture_details fields for datatable
  
  def manufacturer
    manufacture_details&.dig('manufacturer_name')
  end

  def manufactured_item
    manufacture_details&.dig('manufactured_item')
  end

  # Override as_json to include virtual attributes
  def as_json(options = {})
    super(options).merge(
      'manufacturer' => manufacturer,
      'manufactured_item' => manufactured_item
    )
  end
end
