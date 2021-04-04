require 'net/http'
require 'base64'
require 'json'
class ProductsController < ApplicationController
  def index
    @category_id = params[:category_id]
    @products = Category.find(@category_id).products
  end

  def show
    @category_id = params[:category_id]
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
      redirect_to category_product_path(product.category, product)
    else
      redirect_to new_category_product_path(Category.find(product.category_id), product)
    end
  end

  def edit
    redirect_unless_admin_signed_in
    @category_id = params[:category_id]
    @product = Product.find(params[:id])
  end

  def update
    product = Product.find(params[:id])
    if update_product(product)
      redirect_to category_product_path(product.category, product)
    else
      redirect_to edit_category_product_path(product.category, product)
    end
  end

  def destroy
    category = Category.find(params[:category_id])
    product = Product.find(params[:id])
    if product.destroy
      flash[:notice] = "Destroyed product #{params[:id]}"
      redirect_to category_products_path(category)
    else
      flash[:error] = "Failed to destroy product #{params[:id]}"
      redirect_to edit_category_product_path(category, product)
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
      flash[:error] = "Failed to create product, errors: #{product.errors.full_messages}"
      false
    end
  end

  def update_product(product)
    if product.update(product_params(:name, :description, :tags, :price, :price_unit, :image, :category_id))
      flash[:notice] = "Updated product #{product.name} with ID #{product.id}"
      true
    else
      flash[:error] = 'Failed to save product info'
      false
    end
  end

  def product_params(*args)
    params.require(:product).permit(*args)
  end
end
