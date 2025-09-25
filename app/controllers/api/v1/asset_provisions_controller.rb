class Api::V1::AssetProvisionsController < ApplicationController
  before_action :set_asset_provision, only: %i[ show update destroy ]

  def index
    page = params[:page].to_i.positive? ? params[:page].to_i : 1
    per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 5
    per_page = [per_page, 100].min
    per_page = [per_page, 1].max
    offset = (page - 1) * per_page

    total_count = AssetProvision.count
    items = AssetProvision.limit(per_page).offset(offset)

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
    render json: @asset_provision
  end

  def create
    attrs = asset_provision_params.to_h

    product_items = attrs.delete(:product_items)

    item = AssetProvision.new(attrs)
    if item.save
      # Create/update child assets from productItems to keep API stable
      if product_items.present?
        product_items.each do |pi|
          uid = pi[:uid] || pi['uid']
          next if uid.blank?
          asset = Asset.find_or_initialize_by(uid: uid)
          asset.asset_provision = item
          asset.qty = pi[:qty] || pi['qty']
          asset.status = pi[:status] || pi['status']
          asset.product_code ||= item.product_code&.to_s
          asset.site ||= item.site
          asset.location ||= item.location
          asset.save!
        end
        # Persist original product_items JSON for response compatibility
        item.update_column(:product_items, product_items)
      end
      render json: item, status: :created
    else
      render json: { errors: item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    attrs = asset_provision_params.to_h
    product_items = attrs.delete(:product_items)

    if @asset_provision.update(attrs)
      # Update existing assets based on provided productItems; do not create/delete here to avoid surprises
      if product_items.present?
        product_items.each do |pi|
          uid = pi[:uid] || pi['uid']
          next if uid.blank?
          asset = Asset.find_or_initialize_by(uid: uid)
          asset.asset_provision = @asset_provision
          asset.qty = pi[:qty] || pi['qty'] if (pi[:qty] || pi['qty']).present?
          asset.status = pi[:status] || pi['status'] if (pi[:status] || pi['status']).present?
          asset.product_code ||= @asset_provision.product_code&.to_s
          asset.site ||= @asset_provision.site
          asset.location ||= @asset_provision.location
          asset.save!
        end
        # Persist JSON mirror for response compatibility
        @asset_provision.update_column(:product_items, product_items)
      end
      render json: @asset_provision
    else
      render json: { errors: @asset_provision.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @asset_provision.destroy
    head :no_content
  end

  def filter
    items = AssetProvision.includes(:assets).references(:assets)

    items = items.where(product_code: params[:productCode]) if params[:productCode].present?
    items = items.where("site ILIKE ?", "%#{params[:site]}%") if params[:site].present?
    items = items.where("location ILIKE ?", "%#{params[:location]}%") if params[:location].present?
    items = items.where("location_type ILIKE ?", "%#{params[:locationType]}%") if params[:locationType].present?
    items = items.where(quantity: params[:quantity]) if params[:quantity].present?

    if params[:search].present?
      search_term = "%#{params[:search]}%"
      items = items.where(
        "site ILIKE ? OR location ILIKE ? OR location_type ILIKE ? OR product_code::text ILIKE ? OR quantity::text ILIKE ?",
        search_term, search_term, search_term, search_term, search_term
      )
    end

    if params[:productItems].present?
      pi = params[:productItems]
      if pi.is_a?(Array)
        uids = pi.map { |x| x[:uid] || x['uid'] }.compact
        items = items.where(assets: { uid: uids }) if uids.any?
      else
        items = items.where("assets.uid = ?", pi[:uid].to_s) if pi[:uid].present?
        items = items.where("assets.status ILIKE ?", "%#{pi[:status]}%") if pi[:status].present?
      end
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
    items = AssetProvision.includes(:assets)
    allowed_fields = %w[product_code site location location_type quantity created_at updated_at]
    sort_field = params[:field]
    sort_direction = params[:direction]&.downcase == 'desc' ? 'DESC' : 'ASC'

    if sort_field.present? && allowed_fields.include?(sort_field)
      items = items.order("#{sort_field} #{sort_direction}")
    else
      items = items.order(created_at: :desc)
    end

    render json: items
  end

  private

  def set_asset_provision
    @asset_provision = AssetProvision.find(params[:id])
  end

  def asset_provision_params
    params.require(:asset_provision).permit(
      :productCode,
      :site,
      :location,
      :locationType,
      :quantity,
      :dateCreated,
      :lastUpdated,
      productItems: [
        :id,
        :uid,
        :qty,
        :status
      ]
    ).tap do |whitelisted|
      whitelisted[:product_code] = whitelisted.delete(:productCode) if whitelisted[:productCode]
      whitelisted[:location_type] = whitelisted.delete(:locationType) if whitelisted[:locationType]
      whitelisted[:product_items] = whitelisted.delete(:productItems) if whitelisted[:productItems]
      # Map optional timestamps if provided, and remove camelCase keys
      if whitelisted[:dateCreated]
        whitelisted[:created_at] = whitelisted.delete(:dateCreated)
      end
      if whitelisted[:lastUpdated]
        whitelisted[:updated_at] = whitelisted.delete(:lastUpdated)
      end
    end
  end
end




