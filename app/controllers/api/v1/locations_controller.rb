class Api::V1::LocationsController < ApplicationController
  before_action :set_location, only: %i[ show update destroy ]

  def index
    page = params[:page].to_i.positive? ? params[:page].to_i : 1
    per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 5

    per_page = [per_page, 100].min
    per_page = [per_page, 1].max

    offset = (page - 1) * per_page

    total_count = Location.count
    locations = Location.limit(per_page).offset(offset)

    total_pages = (total_count.to_f / per_page).ceil
    has_next_page = page < total_pages
    has_prev_page = page > 1

    render json: {
      data: locations,
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

  def show
    render json: @location
  end

  def create
    location = Location.new(location_params)
    if location.save
      render json: location, status: :created
    else
      render json: { errors: location.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @location.update(location_params)
      render json: @location
    else
      render json: { errors: @location.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @location.destroy
    head :no_content
  end

  def filter
    locations = Location.all

    # Case-insensitive partial matches
    locations = locations.where("code ILIKE ?", "%#{params[:code]}%") if params[:code].present?
    locations = locations.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
    locations = locations.where("site ILIKE ?", "%#{params[:site]}%") if params[:site].present?
    locations = locations.where("description ILIKE ?", "%#{params[:description]}%") if params[:description].present?
    locations = locations.where("location_type ILIKE ?", "%#{params[:location_type]}%") if params[:location_type].present?

    # Global search
    if params[:search].present?
      term = "%#{params[:search]}%"
      locations = locations.where("code ILIKE ? OR name ILIKE ? OR site ILIKE ? OR description ILIKE ? OR location_type ILIKE ?", term, term, term, term, term)
    end

    if params[:page].present? || params[:per_page].present?
      page = params[:page].to_i.positive? ? params[:page].to_i : 1
      per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 5
      per_page = [per_page, 100].min
      per_page = [per_page, 1].max
      offset = (page - 1) * per_page
      total_count = locations.count
      paginated = locations.limit(per_page).offset(offset)
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
        data: locations,
        total: locations.count,
        pagination: {
          current_page: 1,
          per_page: locations.size,
          total_count: locations.count,
          total: locations.count,
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
    locations = Location.all

    allowed_fields = %w[ code name site description location_type created_at updated_at ]
    sort_field = params[:field]
    sort_direction = params[:direction]&.downcase == 'desc' ? 'DESC' : 'ASC'

    if sort_field.present? && allowed_fields.include?(sort_field)
      locations = locations.order("#{sort_field} #{sort_direction}")
    else
      locations = locations.order(:name)
    end

    render json: locations
  end

  private

  def set_location
    @location = Location.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:code, :name, :site, :description, :location_type)
  end
end
