class DimensionsController < ApplicationController
  def new
    @admin = redirect_unless_admin_signed_in
    @category_id = params[:category_id]
    @product_id = params[:product_id]
    @dimension = Dimension.new
  end

  def create
    dimension = Dimension.new(dimension_params(:length, :width, :height, :weight, :distance_unit, :weight_unit,
                                               price_modifier_attributes: %i[number unit]))
    dimension.product_id = params[:product_id]
    if dimension.save
      flash[:notice] = "Created dimension #{dimension.id}"
      redirect_to category_product_path(dimension.product.category, dimension.product)
    else
      flash[:error] = 'Failed to create dimension'
      redirect_to new_category_product_dimension_path(params[:category_id], params[:product_id])
    end
  end

  def edit
    @admin = redirect_unless_admin_signed_in
    @category_id = params[:category_id]
    @product_id = params[:product_id]
    @dimension = Dimension.find(params[:id])
  end

  def update
    dimension = Dimension.find(params[:id])
    dimension.update(dimension_params(:length, :width, :height, :weight, :distance_unit, :weight_unit))
    dimension.price_modifier.update(price_modifier_params(:number, :unit))
    redirect_to category_product_path(dimension.product.category, dimension.product)
  end

  def destroy
    dimension = Dimension.find(params[:id])
    product = dimension.product
    category = product.category
    if dimension.destroy
      flash[:notice] = "Destroyed dimension #{params[:id]}"
      redirect_to category_product_path(category, product)
    else
      flash[:error] = "Failed to destroy dimension #{params[:id]}"
      redirect_to edit_category_product_dimension_path(dimension.product.category, dimension.product, dimension)
    end
  end

  private

  def price_modifier_params(*args)
    params.require(:dimension).permit(:price_modifier_attributes).permit([*args])
  end

  def dimension_params(*args)
    params.require(:dimension).permit(*args)
  end
end
