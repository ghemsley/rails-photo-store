class PriceModifiersController < ApplicationController
  def edit
    @admin = redirect_unless_admin_signed_in
    @category_id = params[:category_id]
    @product_id = params[:product_id]
    @dimension_id = params[:dimension_id]
    @price_modifier = PriceModifier.find(params[:id])
  end

  def update
    price_modifier = PriceModifier.find(params[:id])
    price_modifier.update(price_modifier_params(:number, :unit))
    redirect_to category_product_path(price_modifier.dimension.product.category, price_modifier.dimension.product)
  end

  private
  
  def price_modifier_params(*args)
    params.require(:price_modifier).permit(*args)
  end
end
