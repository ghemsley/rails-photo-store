class PriceModifiersController < ApplicationController
  def edit
    redirect_unless_admin_signed_in
    @price_modifier = PriceModifier.find(params[:id])
    @category_id = @price_modifier.dimension.product.category_id
    @product_id = @price_modifier.dimension.product_id
    @dimension_id = @price_modifier.dimension_id
  end

  def update
    price_modifier = PriceModifier.find(params[:id])
    if price_modifier.update(price_modifier_params(:number, :unit))
      flash[:notice] = "Updated price modifier #{price_modifier.id}"
      redirect_to product_path(price_modifier.dimension.product)
    else
      @price_modifier = price_modifier
      @category_id = @price_modifier.dimension.product.category_id
      @product_id = @price_modifier.dimension.product_id
      @dimension_id = @price_modifier.dimension_id
      render :edit
    end
  end

  private
  
  def price_modifier_params(*args)
    params.require(:price_modifier).permit(*args)
  end
end
