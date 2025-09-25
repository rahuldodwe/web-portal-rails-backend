class Api::V1::ProductTypesController < ApplicationController
  before_action :set_product_type, only: %i[ show update destroy ]

  def index
    product_types = ProductType.all
    render json: product_types
  end

  def show
    render json: @product_type
  end

  def create
    product_type = ProductType.new(product_type_params)
    if product_type.save
      render json: product_type, status: :created
    else
      render json: { errors: product_type.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @product_type.update(product_type_params)
      render json: @product_type
    else
      render json: { errors: @product_type.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @product_type.destroy
    head :no_content
  end

  def filter
    items = ProductType.all

    items = items.where("identifier ILIKE ?", "%#{params[:identifier]}%") if params[:identifier].present?
    items = items.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
    items = items.where("description ILIKE ?", "%#{params[:description]}%") if params[:description].present?

    if params[:search].present?
      term = "%#{params[:search]}%"
      items = items.where("identifier ILIKE ? OR name ILIKE ? OR description ILIKE ?", term, term, term)
    end

    if params[:page].present? || params[:per_page].present?
      page = params[:page].to_i.positive? ? params[:page].to_i : 1
      per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 5
      per_page = [per_page, 100].min
      per_page = [per_page, 1].max
      offset = (page - 1) * per_page

      total_count = items.count
      paginated = items.limit(per_page).offset(offset)
      total_pages = (total_count.to_f / per_page).ceil
      has_next_page = page < total_pages
      has_prev_page = page > 1

      render json: {
        data: paginated,
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
    else
      render json: {
        data: items,
        total: items.count,
        pagination: {
          current_page: 1,
          per_page: items.size,
          total_count: items.count,
          total: items.count,
          total_pages: 1,
          has_next_page: false,
          has_prev_page: false,
          next_page: nil,
          prev_page: nil
        }
      }
    end
  end

  def paginate
    page = params[:page].to_i.positive? ? params[:page].to_i : 1
    per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 5
    per_page = [per_page, 100].min
    per_page = [per_page, 1].max
    offset = (page - 1) * per_page

    total_count = ProductType.count
    items = ProductType.limit(per_page).offset(offset)
    total_pages = (total_count.to_f / per_page).ceil
    has_next_page = page < total_pages
    has_prev_page = page > 1

    render json: {
      data: items,
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

  def sort
    items = ProductType.all
    allowed_fields = %w[identifier name description created_at updated_at]
    sort_field = params[:field]
    sort_direction = params[:direction]&.downcase == 'desc' ? 'DESC' : 'ASC'

    if sort_field.present? && allowed_fields.include?(sort_field)
      items = items.order("#{sort_field} #{sort_direction}")
    else
      items = items.order(:name)
    end

    render json: items
  end

  private

  def set_product_type
    @product_type = ProductType.find(params[:id])
  end

  def product_type_params
    params.require(:product_type).permit(:identifier, :name, :description)
  end
end
