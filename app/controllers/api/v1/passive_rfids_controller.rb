class Api::V1::PassiveRfidsController < ApplicationController
  before_action :set_passive_rfid, only: %i[ show update destroy ]

  def index
    page = params[:page].to_i.positive? ? params[:page].to_i : 1
    per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 5
    per_page = [per_page, 100].min
    per_page = [per_page, 1].max
    offset = (page - 1) * per_page

    total_count = PassiveRfid.count
    items = PassiveRfid.limit(per_page).offset(offset)

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
    render json: @passive_rfid
  end

  def create
    # Support variable antennas size; if antenna_count present and antennas omitted, prefill
    attrs = passive_rfid_params.to_h
    if attrs["antenna_count"].present? && (!attrs.key?("antennas") || attrs["antennas"].blank?)
      count = attrs["antenna_count"].to_i
      attrs["antennas"] = (1..count).map do |i|
        {
          "antenna" => i,
          "rxSensitivity" => nil,
          "txPower" => nil,
          "enabled" => false
        }
      end
    end

    item = PassiveRfid.new(attrs)
    if item.save
      render json: item, status: :created
    else
      render json: { errors: item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @passive_rfid.update(passive_rfid_params)
      render json: @passive_rfid
    else
      render json: { errors: @passive_rfid.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @passive_rfid.destroy
    head :no_content
  end

  def filter
    items = PassiveRfid.all

    items = items.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
    items = items.where("host_name ILIKE ?", "%#{params[:hostName]}%") if params[:hostName].present?
    items = items.where(port: params[:port]) if params[:port].present?
    items = items.where("manufacturer ILIKE ?", "%#{params[:manufacturer]}%") if params[:manufacturer].present?
    items = items.where("model ILIKE ?", "%#{params[:model]}%") if params[:model].present?
    items = items.where("description ILIKE ?", "%#{params[:description]}%") if params[:description].present?
    items = items.where(antenna_count: params[:antennaCount]) if params[:antennaCount].present?
    items = items.where("edge_device ILIKE ?", "%#{params[:edgeDevice]}%") if params[:edgeDevice].present?
    items = items.where(enabled: params[:enabled]) if params[:enabled].present?

    # search
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      items = items.where(
        "name ILIKE ? OR host_name ILIKE ? OR manufacturer ILIKE ? OR model ILIKE ? OR description ILIKE ? OR edge_device ILIKE ? OR port::text ILIKE ? OR antenna_count::text ILIKE ?",
        search_term, search_term, search_term, search_term, search_term, search_term, search_term, search_term
      )
    end

    # antennas nested search
    if params[:antennas].present?
      ant = params[:antennas]
      items = items.where("EXISTS (SELECT 1 FROM jsonb_array_elements(antennas) as a WHERE (a->>'antenna')::integer = ?)", ant[:antenna].to_i) if ant[:antenna].present?
      items = items.where("EXISTS (SELECT 1 FROM jsonb_array_elements(antennas) as a WHERE (a->>'enabled')::boolean = ?)", ActiveModel::Type::Boolean.new.cast(ant[:enabled])) if ant[:enabled].present?
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
    items = PassiveRfid.all
    allowed_fields = %w[name host_name port manufacturer model antenna_count enabled edge_device created_at updated_at]
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

  def set_passive_rfid
    @passive_rfid = PassiveRfid.find(params[:id])
  end

  def passive_rfid_params
    params.require(:passive_rfid).permit(
      :name,
      :hostName,
      :port,
      :manufacturer,
      :model,
      :description,
      :antennaCount,
      :gpiConfig,
      :gpoConfig,
      :enabled,
      :edgeDevice,
      antennas: [
        :antenna,
        :rxSensitivity,
        :txPower,
        :enabled
      ]
    ).tap do |whitelisted|
      # Map camelCase incoming params to snake_case DB columns
      if whitelisted[:hostName]
        whitelisted[:host_name] = whitelisted.delete(:hostName)
      end
      if whitelisted[:antennaCount]
        whitelisted[:antenna_count] = whitelisted.delete(:antennaCount)
      end
      if whitelisted[:gpiConfig]
        whitelisted[:gpi_config] = whitelisted.delete(:gpiConfig)
      end
      if whitelisted[:gpoConfig]
        whitelisted[:gpo_config] = whitelisted.delete(:gpoConfig)
      end
      if whitelisted[:edgeDevice]
        whitelisted[:edge_device] = whitelisted.delete(:edgeDevice)
      end
    end
  end
end


