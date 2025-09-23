class Api::V1::EdgeDevicesController < ApplicationController
  before_action :set_edge_device, only: %i[ show update destroy ]

  def index
    page = params[:page].to_i.positive? ? params[:page].to_i : 1
    per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 5
    per_page = [per_page, 100].min
    per_page = [per_page, 1].max
    offset = (page - 1) * per_page

    total_count = EdgeDevice.count
    items = EdgeDevice.limit(per_page).offset(offset)

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

  def paginate
    index
  end

  def show
    render json: @edge_device
  end

  def create
    edge_device = EdgeDevice.new(edge_device_params)
    if edge_device.save
      render json: edge_device, status: :created
    else
      render json: { errors: edge_device.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @edge_device.update(edge_device_params)
      render json: @edge_device
    else
      render json: { errors: @edge_device.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @edge_device.destroy
    head :no_content
  end

  def filter
    items = EdgeDevice.all

    items = items.where(code: params[:code]) if params[:code].present?
    items = items.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
    items = items.where("description ILIKE ?", "%#{params[:description]}%") if params[:description].present?
    items = items.where(registered: params[:registered]) if params[:registered].present?
    items = items.where(status: params[:status]) if params[:status].present?

    # nested JSONB filters
    if params[:serial].present?
      serial = params[:serial]
      items = items.where("serial->>'baudRate' = ?", serial[:baudRate].to_s) if serial[:baudRate].present?
      items = items.where("serial->>'dataBits' = ?", serial[:dataBits].to_s) if serial[:dataBits].present?
      items = items.where("serial->>'stopBits' = ?", serial[:stopBits].to_s) if serial[:stopBits].present?
      items = items.where("serial->>'parity' ILIKE ?", "%#{serial[:parity]}%") if serial[:parity].present?
    end

    if params[:tcp].present?
      tcp = params[:tcp]
      items = items.where("tcp->>'ipAddress' ILIKE ?", "%#{tcp[:ipAddress]}%") if tcp[:ipAddress].present?
      items = items.where("tcp->>'tcpPort' = ?", tcp[:tcpPort].to_s) if tcp[:tcpPort].present?
    end

    if params[:static].present?
      static = params[:static]
      items = items.where("(static->>'latitude')::numeric = ?", static[:latitude]) if static[:latitude].present?
      items = items.where("(static->>'longitude')::numeric = ?", static[:longitude]) if static[:longitude].present?
    end

    # Text search across multiple fields
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      items = items.where(
        "name ILIKE ? OR description ILIKE ? OR code::text ILIKE ? OR serial->>'parity' ILIKE ? OR tcp->>'ipAddress' ILIKE ?",
        search_term, search_term, search_term, search_term, search_term
      )
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

  def sort
    items = EdgeDevice.all

    allowed_fields = %w[code name registered status created_at updated_at]
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

  def set_edge_device
    @edge_device = EdgeDevice.find(params[:id])
  end

  def edge_device_params
    params.require(:edge_device).permit(
      :code,
      :name,
      :description,
      :registered,
      :status,
      serial: [
        :baudRate,
        :dataBits,
        :stopBits,
        :parity
      ],
      tcp: [
        :ipAddress,
        :tcpPort
      ],
      static: [
        :latitude,
        :longitude
      ]
    )
  end
end



