class PriceModifiersController < ApplicationController
  def edit
    redirect_unless_admin_signed_in
    @category_id = params[:category_id]
    @product_id = params[:product_id]
    @dimension_id = params[:dimension_id]
    @price_modifier = PriceModifier.find(params[:id])
  end

  def update
    price_modifier = PriceModifier.find(params[:id])
    if price_modifier.update(price_modifier_params(:number, :unit))
      flash[:notice] = "Updated price modifier #{price_modifier.id}"
      redirect_to category_product_path(price_modifier.dimension.product.category, price_modifier.dimension.product)
    else
      render :edit
    end
  end

  private
  
  def price_modifier_params(*args)
    params.require(:price_modifier).permit(*args)
  end
end
