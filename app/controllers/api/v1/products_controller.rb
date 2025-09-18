class Api::V1::ProductsController < ApplicationController
  before_action :set_product, only: %i[ show update destroy ]

  def index
    products = Product.all
    render json: products
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
      :manufacturer,
      :manufactured_item,
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
