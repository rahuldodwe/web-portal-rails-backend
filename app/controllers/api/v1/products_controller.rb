class Api::V1::ProductsController < ApplicationController
  before_action :set_product, only: %i[ show update destroy ]

  def index
    # Pagination params
    page = params[:page].to_i.positive? ? params[:page].to_i : 1
    per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 5

    per_page = [per_page, 100].min
    per_page = [per_page, 1].max

    offset = (page - 1) * per_page

    total_count = Product.count
    products = Product.limit(per_page).offset(offset)

    total_pages = (total_count.to_f / per_page).ceil
    has_next_page = page < total_pages
    has_prev_page = page > 1

    render json: {
      data: products,
      total: total_count,
      pagination: {
        current_page: page,
        per_page: per_page,
        total_count: total_count,
        total: total_count,
        total_pages: total_pages,
        has_next_page: has_next_page,
        has_prev_page: has_prev_page,
        next_page: has_next_page ? page + 1 : nil,
        prev_page: has_prev_page ? page - 1 : nil
      }
    }
  end

  def paginate
    # Get pagination parameters
    page = params[:page].to_i.positive? ? params[:page].to_i : 1
    per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 5
    
    # Limit per_page to reasonable range (1-100)
    per_page = [per_page, 100].min
    per_page = [per_page, 1].max

    # Calculate offset
    offset = (page - 1) * per_page

    # Get total count
    total_count = Product.count

    # Get paginated products
    products = Product.limit(per_page).offset(offset)

    # Calculate pagination metadata
    total_pages = (total_count.to_f / per_page).ceil
    has_next_page = page < total_pages
    has_prev_page = page > 1

    # Prepare response
    response_data = {
      data: products,
      total: total_count,
      pagination: {
        current_page: page,
        per_page: per_page,
        total_count: total_count,
        total: total_count,
        total_pages: total_pages,
        has_next_page: has_next_page,
        has_prev_page: has_prev_page,
        next_page: has_next_page ? page + 1 : nil,
        prev_page: has_prev_page ? page - 1 : nil
      }
    }

    render json: response_data
  end

  def show
    render json: @product
  end

  def create
    product = Product.new(product_params)
    if product.save
      render json: product, status: :created
    else
      render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      render json: @product
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    head :no_content
  end

  def filter
    products = Product.all

    # Basic filtering by any field (case-insensitive partial matching for text fields)
    products = products.where("product_code ILIKE ?", "%#{params[:product_code]}%") if params[:product_code].present?
    products = products.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
    products = products.where("product_category ILIKE ?", "%#{params[:product_category]}%") if params[:product_category].present?
    products = products.where("product_type ILIKE ?", "%#{params[:product_type]}%") if params[:product_type].present?
    products = products.where(inventory: params[:inventory]) if params[:inventory].present?
    products = products.where("inventory_type ILIKE ?", "%#{params[:inventory_type]}%") if params[:inventory_type].present?
    products = products.where("description ILIKE ?", "%#{params[:description]}%") if params[:description].present?
    products = products.where(active: params[:active]) if params[:active].present?
    products = products.where(consumable: params[:consumable]) if params[:consumable].present?

    # Numeric field filtering
    products = products.where("net_weight >= ?", params[:min_net_weight]) if params[:min_net_weight].present?
    products = products.where("net_weight <= ?", params[:max_net_weight]) if params[:max_net_weight].present?
    products = products.where("gross_weight >= ?", params[:min_gross_weight]) if params[:min_gross_weight].present?
    products = products.where("gross_weight <= ?", params[:max_gross_weight]) if params[:max_gross_weight].present?
    products = products.where("cost >= ?", params[:min_cost]) if params[:min_cost].present?
    products = products.where("cost <= ?", params[:max_cost]) if params[:max_cost].present?

    # JSONB field filtering
    if params[:identifier_type].present?
      products = products.where("identification_details->>'identifier_type' = ?", params[:identifier_type])
    end
    if params[:primary_identifier].present?
      products = products.where("identification_details->>'primary_identifier' ILIKE ?", "%#{params[:primary_identifier]}%")
    end
    if params[:item_upc].present?
      products = products.where("identification_details->>'item_upc' = ?", params[:item_upc])
    end
    if params[:case_upc].present?
      products = products.where("identification_details->>'case_upc' = ?", params[:case_upc])
    end
    if params[:uom].present?
      products = products.where("identification_details->>'uom' = ?", params[:uom])
    end

    # Measurement details filtering
    if params[:min_each_weight].present?
      products = products.where("(measurement_details->>'each_weight')::numeric >= ?", params[:min_each_weight])
    end
    if params[:max_each_weight].present?
      products = products.where("(measurement_details->>'each_weight')::numeric <= ?", params[:max_each_weight])
    end
    if params[:case_quantity].present?
      products = products.where("(measurement_details->>'case_quantity')::integer = ?", params[:case_quantity])
    end

    # Manufacture details filtering
    if params[:manufacturer_name].present?
      products = products.where("manufacture_details->>'manufacturer_name' ILIKE ?", "%#{params[:manufacturer_name]}%")
    end
    if params[:supplier_name].present?
      products = products.where("manufacture_details->>'supplier_name' ILIKE ?", "%#{params[:supplier_name]}%")
    end
    if params[:make].present?
      products = products.where("manufacture_details->>'make' ILIKE ?", "%#{params[:make]}%")
    end
    if params[:model].present?
      products = products.where("manufacture_details->>'model' ILIKE ?", "%#{params[:model]}%")
    end

    # Text search across multiple fields
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      products = products.where(
        "name ILIKE ? OR product_code ILIKE ? OR description ILIKE ? OR product_type ILIKE ? OR product_category ILIKE ? OR inventory_type ILIKE ? OR manufacture_details->>'manufacturer_name' ILIKE ? OR manufacture_details->>'manufactured_item' ILIKE ?",
        search_term, search_term, search_term, search_term, search_term, search_term, search_term, search_term
      )
    end

    # Check if pagination is requested
    if params[:page].present? || params[:per_page].present?
      # Get pagination parameters
      page = params[:page].to_i.positive? ? params[:page].to_i : 1
      per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 5
      
      # Limit per_page to reasonable range (1-100)
      per_page = [per_page, 100].min
      per_page = [per_page, 1].max

      # Calculate offset
      offset = (page - 1) * per_page

      # Get total count of filtered results
      total_count = products.count

      # Get paginated filtered products
      paginated_products = products.limit(per_page).offset(offset)

      # Calculate pagination metadata
      total_pages = (total_count.to_f / per_page).ceil
      has_next_page = page < total_pages
      has_prev_page = page > 1

      # Prepare response with pagination
      response_data = {
        data: paginated_products,
        total: total_count,
        pagination: {
          current_page: page,
          per_page: per_page,
          total_count: total_count,
          total: total_count,
          total_pages: total_pages,
          has_next_page: has_next_page,
          has_prev_page: has_prev_page,
          next_page: has_next_page ? page + 1 : nil,
          prev_page: has_prev_page ? page - 1 : nil
        }
      }

      render json: response_data
    else
      render json: {
        data: products,
        total: products.count,
        pagination: {
          current_page: 1,
          per_page: products.size,
          total_count: products.count,
          total: products.count,
          total_pages: 1,
          has_next_page: false,
          has_prev_page: false,
          next_page: nil,
          prev_page: nil
        }
      }
    end
  end

  def sort
    products = Product.all

    # Validate sort field
    allowed_fields = %w[
      product_code name product_category product_type
      inventory_type description no_of_packs active consumable net_weight gross_weight cost
      created_at updated_at
    ]

    sort_field = params[:field]
    sort_direction = params[:direction]&.downcase == 'desc' ? 'DESC' : 'ASC'

    if sort_field.present? && allowed_fields.include?(sort_field)
      products = products.order("#{sort_field} #{sort_direction}")
    else
      # Default sorting by name if no valid field provided
      products = products.order(:name)
    end

    render json: products
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :product_code,
      :name,
      :product_category,
      :product_type,
      :inventory,
      :inventory_type,
      :description,
      :net_weight,
      :gross_weight,
      :cost,
      :no_of_packs,
      :active,
      :consumable,
      identification_details: [
        :identifier_type,
        :primary_identifier,
        :item_upc,
        :case_upc,
        :conveyance,
        :revision,
        :uom
      ],
      measurement_details: [
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
      ],
      manufacture_details: [
        :manufacturer_name,
        :manufactured_item,
        :make,
        :model,
        :supplier_name,
        :supplier_item
      ]
    )
  end
end
