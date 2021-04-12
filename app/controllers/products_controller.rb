require 'net/http'
require 'base64'
require 'json'
class ProductsController < ApplicationController
  def index
    @category_id = params[:category_id]
    @products = Category.find(@category_id).products
  end

  def show
    @product = Product.find(params[:id])
  end

  def new
    redirect_unless_admin_signed_in
    @category_id = params[:category_id]
    @product = Product.new
  end

  def create
    product = Product.new
    if create_product(product)
      redirect_to product_path(product)
    else
      @category_id = params[:product][:category_id]
      @product = product
      render :new
    end
  end

  def edit
    redirect_unless_admin_signed_in
    @product = Product.find(params[:id])
  end

  def update
    product = Product.find(params[:id])
    if update_product(product)
      redirect_to product_path(product)
    else
      @category_id = params[:product][:category_id]
      @product = product
      render :edit
    end
  end

  def destroy
    product = Product.find(params[:id])
    category_id = product.category_id
    if product.destroy
      flash[:notice] = "Destroyed product #{params[:id]}"
      redirect_to category_path(category_id)
    else
      flash[:error] = "Failed to destroy product #{params[:id]}"
      redirect_to edit_product_path(product)
    end
  end

  def popular
    @products_with_amounts = Product.most_popular
  end

  private

  def create_product(product)
    if product.update(product_params(:name, :description, :tags, :price, :price_unit, :image, :category_id,
                                     dimensions_attributes: [:length, :width, :height, :weight, :distance_unit, :weight_unit,
                                                             { price_modifier_attributes: %i[number unit] }]))
      flash[:notice] = "Created product #{product.name} with ID #{product.id},
                        dimensions #{product.dimensions.collect(&:id)},
                        price modifiers #{product.price_modifiers.collect(&:id)}"
      true
    else
      false
    end
  end

  def update_product(product)
    if product.update(product_params(:name, :description, :tags, :price, :price_unit, :image, :category_id))
      flash[:notice] = "Updated product #{product.name} with ID #{product.id}"
      true
    else
      false
    end
  end

  def product_params(*args)
    params.require(:product).permit(*args)
  end
end
