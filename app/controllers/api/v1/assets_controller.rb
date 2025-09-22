class Api::V1::AssetsController < ApplicationController
  before_action :set_asset, only: %i[ show update destroy ]

  def index
    page = params[:page].to_i.positive? ? params[:page].to_i : 1
    per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 5

    per_page = [per_page, 100].min
    per_page = [per_page, 1].max

    offset = (page - 1) * per_page

    total_count = Asset.count
    assets = Asset.limit(per_page).offset(offset)

    total_pages = (total_count.to_f / per_page).ceil
    has_next_page = page < total_pages
    has_prev_page = page > 1

    render json: {
      data: assets,
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
    render json: @asset
  end

  def create
    asset = Asset.new(asset_params)
    if asset.save
      render json: asset, status: :created
    else
      render json: { errors: asset.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @asset.update(asset_params)
      render json: @asset
    else
      render json: { errors: @asset.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @asset.destroy
    head :no_content
  end

  def filter
    assets = Asset.all

    assets = assets.where("uid ILIKE ?", "%#{params[:uid]}%") if params[:uid].present?
    assets = assets.where("product_code ILIKE ?", "%#{params[:product_code]}%") if params[:product_code].present?
    assets = assets.where("manufacturer ILIKE ?", "%#{params[:manufacturer]}%") if params[:manufacturer].present?
    assets = assets.where("batch_no ILIKE ?", "%#{params[:batch_no]}%") if params[:batch_no].present?
    assets = assets.where("site ILIKE ?", "%#{params[:site]}%") if params[:site].present?
    assets = assets.where("description ILIKE ?", "%#{params[:description]}%") if params[:description].present?
    assets = assets.where("asset_type ILIKE ?", "%#{params[:asset_type]}%") if params[:asset_type].present?
    assets = assets.where("status ILIKE ?", "%#{params[:status]}%") if params[:status].present?
    assets = assets.where("location ILIKE ?", "%#{params[:location]}%") if params[:location].present?
    assets = assets.where("owner ILIKE ?", "%#{params[:owner]}%") if params[:owner].present?
    assets = assets.where("assignee ILIKE ?", "%#{params[:assignee]}%") if params[:assignee].present?

    # Date filters (range support)
    assets = assets.where("last_validation_date >= ?", params[:min_last_validation_date]) if params[:min_last_validation_date].present?
    assets = assets.where("last_validation_date <= ?", params[:max_last_validation_date]) if params[:max_last_validation_date].present?
    assets = assets.where("last_move_date >= ?", params[:min_last_move_date]) if params[:min_last_move_date].present?
    assets = assets.where("last_move_date <= ?", params[:max_last_move_date]) if params[:max_last_move_date].present?
    assets = assets.where("last_physical_inventory_date >= ?", params[:min_last_physical_inventory_date]) if params[:min_last_physical_inventory_date].present?
    assets = assets.where("last_physical_inventory_date <= ?", params[:max_last_physical_inventory_date]) if params[:max_last_physical_inventory_date].present?

    if params[:search].present?
      term = "%#{params[:search]}%"
      assets = assets.where("uid ILIKE ? OR product_code ILIKE ? OR manufacturer ILIKE ? OR batch_no ILIKE ? OR site ILIKE ? OR description ILIKE ? OR asset_type ILIKE ? OR status ILIKE ? OR location ILIKE ? OR owner ILIKE ? OR assignee ILIKE ?", term, term, term, term, term, term, term, term, term, term, term)
    end

    if params[:page].present? || params[:per_page].present?
      page = params[:page].to_i.positive? ? params[:page].to_i : 1
      per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 5
      per_page = [per_page, 100].min
      per_page = [per_page, 1].max
      offset = (page - 1) * per_page
      total_count = assets.count
      paginated = assets.limit(per_page).offset(offset)
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
        data: assets,
        total: assets.count,
        pagination: {
          current_page: 1,
          per_page: assets.size,
          total_count: assets.count,
          total: assets.count,
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

    total_count = Asset.count
    assets = Asset.limit(per_page).offset(offset)

    total_pages = (total_count.to_f / per_page).ceil
    has_next_page = page < total_pages
    has_prev_page = page > 1

    render json: {
      data: assets,
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
    assets = Asset.all

    allowed_fields = %w[ uid product_code manufacturer batch_no site description asset_type status location owner assignee last_validation_date last_move_date last_physical_inventory_date created_at updated_at ]
    sort_field = params[:field]
    sort_direction = params[:direction]&.downcase == 'desc' ? 'DESC' : 'ASC'

    if sort_field.present? && allowed_fields.include?(sort_field)
      assets = assets.order("#{sort_field} #{sort_direction}")
    else
      assets = assets.order(:uid)
    end

    render json: assets
  end

  private

  def set_asset
    @asset = Asset.find(params[:id])
  end

  def asset_params
    params.require(:asset).permit(:uid, :product_code, :manufacturer, :batch_no, :site, :description, :asset_type, :status, :location, :owner, :assignee, :last_validation_date, :last_move_date, :last_physical_inventory_date)
  end
end
