class Product < ApplicationRecord

  validates :product_code, uniqueness: true, presence: true;
  validates :name, presence: true;
  validates :product_category, presence: true;
  validates :product_type, presence: true;
  validates :no_of_packs, numericality: { greater_than: 0 }, allow_nil: true, allow_blank: true;
  validates :net_weight, numericality: { greater_than: 0 }, allow_nil: true, allow_blank: true;
  validates :gross_weight, numericality: { greater_than: 0 }, allow_nil: true, allow_blank: true;
  validates :cost, numericality: { greater_than: 0 }, allow_nil: true, allow_blank: true;

  # Accessors for identification_details (jsonb)
  store_accessor :identification_details,
                 :identifier_type,
                 :primary_identifier,
                 :item_upc,
                 :case_upc,
                 :conveyance,
                 :revision,
                 :uom

  # Validations for identification_details keys
  validates :identification_details, presence: true;
  validates :uom, presence: true;
  validates :primary_identifier, length: { maximum: 255 }, allow_nil: true, allow_blank: true;
  validates :item_upc, length: { maximum: 255 }, allow_nil: true, allow_blank: true;
  validates :case_upc, length: { maximum: 255 }, allow_nil: true, allow_blank: true;
  validates :revision, length: { maximum: 255 }, allow_nil: true, allow_blank: true;
  validate :identifier_type_must_be_string_or_array
  validate :conveyance_must_be_boolean

  # Accessors for measurement_details (jsonb)
  store_accessor :measurement_details,
                 :each_weight,
                 :each_height,
                 :each_length,
                 :each_width,
                 :each_cube,
                 :case_weight,
                 :case_cube,
                 :case_quantity,
                 :case_quantity_per_layer,
                 :layer_qty_per_pallet,
                 :conveyance_type

  # Validations for measurement_details keys (optional numerics > 0)
  validates :each_weight, numericality: { greater_than: 0 }, allow_nil: true, allow_blank: true;
  validates :each_height, numericality: { greater_than: 0 }, allow_nil: true, allow_blank: true;
  validates :each_length, numericality: { greater_than: 0 }, allow_nil: true, allow_blank: true;
  validates :each_width, numericality: { greater_than: 0 }, allow_nil: true, allow_blank: true;
  validates :each_cube, numericality: { greater_than: 0 }, allow_nil: true, allow_blank: true;
  validates :case_weight, numericality: { greater_than: 0 }, allow_nil: true, allow_blank: true;
  validates :case_cube, numericality: { greater_than: 0 }, allow_nil: true, allow_blank: true;
  validates :case_quantity, numericality: { greater_than: 0 }, allow_nil: true, allow_blank: true;
  validates :case_quantity_per_layer, numericality: { greater_than: 0 }, allow_nil: true, allow_blank: true;
  validates :layer_qty_per_pallet, numericality: { greater_than: 0 }, allow_nil: true, allow_blank: true;
  validates :conveyance_type, numericality: { greater_than: 0 }, allow_nil: true, allow_blank: true;

  # Accessors for manufacture_details (jsonb)
  store_accessor :manufacture_details,
                 :manufacturer_name,
                 :manufactured_item,
                 :make,
                 :model,
                 :supplier_name,
                 :supplier_item

  # Validations for manufacture_details keys (optional strings)
  # Manufacture string fields: optional, must be strings if provided (no length limit)
  validate :manufacture_strings_must_be_strings
  validates :make, length: { maximum: 255 }, allow_nil: true, allow_blank: true;
  validates :model, length: { maximum: 255 }, allow_nil: true, allow_blank: true;
  validates :supplier_name, length: { maximum: 255 }, allow_nil: true, allow_blank: true;
  validates :supplier_item, length: { maximum: 255 }, allow_nil: true, allow_blank: true;

  
  
  
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

  private

  def identifier_type_must_be_string_or_array
    return if identifier_type.blank?
    return if identifier_type.is_a?(String) || identifier_type.is_a?(Array)

    errors.add(:identifier_type, 'must be a string or an array')
  end

  def conveyance_must_be_boolean
    return if conveyance.nil?
    return if conveyance.in?([true, false])

    errors.add(:conveyance, 'must be true or false')
  end

  def manufacture_strings_must_be_strings
    %i[manufacturer_name manufactured_item supplier_name].each do |attr|
      value = send(attr)
      next if value.blank?
      unless value.is_a?(String)
        errors.add(attr, 'must be a string')
        next
      end
      if value.strip.match?(/\A[+-]?\d+(\.\d+)?\z/)
        errors.add(attr, 'cannot be a numeric value')
      end
    end
  end
end
