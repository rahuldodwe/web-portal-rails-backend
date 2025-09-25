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
    render json: { error: 'Creation of assets is managed via Asset Provisioning' }, status: :method_not_allowed
  end

  def update
    if @asset.update(asset_params)
      render json: @asset
    else
      render json: { errors: @asset.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    render json: { error: 'Deletion of assets is managed via Asset Provisioning' }, status: :method_not_allowed
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

    # Extended fields (accept both snake_case and camelCase query params)
    primary_identifier = params[:primary_identifier].presence || params[:primaryIdentifier].presence
    assets = assets.where("primary_identifier ILIKE ?", "%#{primary_identifier}%") if primary_identifier

    previous_location = params[:previous_location].presence || params[:PreviousLocation].presence
    assets = assets.where("previous_location ILIKE ?", "%#{previous_location}%") if previous_location

    asset_status = params[:asset_status].presence || params[:assetStatus].presence
    assets = assets.where("asset_status ILIKE ?", "%#{asset_status}%") if asset_status

    item_revision = params[:item_revision].presence || params[:itemRevision].presence
    assets = assets.where(item_revision: item_revision) if item_revision

    condition_param = params[:condition].presence
    assets = assets.where("condition ILIKE ?", "%#{condition_param}%") if condition_param

    quantity_param = params[:quantity].presence
    assets = assets.where(quantity: quantity_param) if quantity_param

    location_move_time = params[:location_move_time].presence || params[:locationMoveTime].presence
    assets = assets.where("location_move_time::text ILIKE ?", "%#{location_move_time}%") if location_move_time

    # Date filters (range support)
    assets = assets.where("last_validation_date >= ?", params[:min_last_validation_date]) if params[:min_last_validation_date].present?
    assets = assets.where("last_validation_date <= ?", params[:max_last_validation_date]) if params[:max_last_validation_date].present?
    assets = assets.where("last_move_date >= ?", params[:min_last_move_date]) if params[:min_last_move_date].present?
    assets = assets.where("last_move_date <= ?", params[:max_last_move_date]) if params[:max_last_move_date].present?
    assets = assets.where("last_physical_inventory_date >= ?", params[:min_last_physical_inventory_date]) if params[:min_last_physical_inventory_date].present?
    assets = assets.where("last_physical_inventory_date <= ?", params[:max_last_physical_inventory_date]) if params[:max_last_physical_inventory_date].present?

    if params[:search].present?
      term = "%#{params[:search]}%"
      assets = assets.where(
        "uid ILIKE ? OR product_code ILIKE ? OR manufacturer ILIKE ? OR batch_no ILIKE ? OR site ILIKE ? OR description ILIKE ? OR asset_type ILIKE ? OR status ILIKE ? OR location ILIKE ? OR owner ILIKE ? OR assignee ILIKE ? OR primary_identifier ILIKE ? OR previous_location ILIKE ? OR asset_status ILIKE ? OR condition ILIKE ?",
        term, term, term, term, term, term, term, term, term, term, term, term, term, term, term
      )
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
    permitted = params.require(:asset).permit(
      :uid,
      :product_code,
      :manufacturer,
      :batch_no,
      :site,
      :description,
      :asset_type,
      :status,
      :location,
      :owner,
      :assignee,
      :last_validation_date,
      :last_move_date,
      :last_physical_inventory_date,
      :primaryIdentifier,
      :locationMoveTime,
      :PreviousLocation,
      :assetStatus,
      :itemRevision,
      :condition,
      :quantity,
      identifiers: [:identifier, :identifierType],
      physicalAttribute: [:expectedSite, :expectedLocation, :mobile, :rfidTagged],
      lifecycle: [
        :dateProduced,
        :ProvisionTime,
        :arrivalTime,
        :intoserviceTime,
        :lastValidationTime,
        :previouslocationMoveTime,
        :endOfLifeDate,
        :outOfServiceTime,
        :lastMaintenanceDate,
        :siteDwellTime,
        :locationDwellTime,
        :statusDwellTime,
        :statusLastUpdated,
        :inWarranty,
        :warrantyEndDate,
        :returnByDate,
        :lastUpdated,
        :putawayComplete,
        :putawatTime
      ],
      history: [:eventType, :description, :time, :user],
      comment: [:comment, :commentBy]
    )

    # Map camelCase to snake_case
    permitted[:primary_identifier] = permitted.delete(:primaryIdentifier) if permitted[:primaryIdentifier]
    permitted[:location_move_time] = permitted.delete(:locationMoveTime) if permitted[:locationMoveTime]
    permitted[:previous_location] = permitted.delete(:PreviousLocation) if permitted[:PreviousLocation]
    permitted[:asset_status] = permitted.delete(:assetStatus) if permitted[:assetStatus]
    permitted[:item_revision] = permitted.delete(:itemRevision) if permitted[:itemRevision]
    permitted[:physical_attribute] = permitted.delete(:physicalAttribute) if permitted[:physicalAttribute]

    # Normalize nested keys if present
    if permitted[:identifiers].present?
      permitted[:identifiers] = {
        identifier: permitted[:identifiers][:identifier],
        identifier_type: permitted[:identifiers][:identifierType]
      }
    end
    if permitted[:physical_attribute].present?
      pa = permitted[:physical_attribute]
      permitted[:physical_attribute] = {
        expected_site: pa[:expectedSite],
        expected_location: pa[:expectedLocation],
        mobile: pa[:mobile],
        rfid_tagged: pa[:rfidTagged]
      }
    end
    if permitted[:lifecycle].present?
      permitted[:lifecycle] = permitted[:lifecycle]
    end

    permitted
  end
end
