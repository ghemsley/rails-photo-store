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
      redirect_to product_path(dimension.product_id)
    else
      @admin = get_admin_if_signed_in
      @dimension = dimension
      @category_id = params[:category_id]
      @product_id = params[:product_id]
      render :new
    end
  end

  def edit
    @admin = redirect_unless_admin_signed_in
    @dimension = Dimension.find(params[:id])
  end

  def update
    dimension = Dimension.find(params[:id])
    if dimension.update(dimension_params(:length, :width, :height, :weight, :distance_unit, :weight_unit))
      flash[:notice] = "Updated dimension #{dimension.id}"
      redirect_to product_path(dimension.product_id)
    else 
      @admin = get_admin_if_signed_in
      @dimension = dimension
      render :edit
    end
  end

  def destroy
    dimension = Dimension.find(params[:id])
    product_id = dimension.product_id
    if dimension.destroy
      flash[:notice] = "Destroyed dimension #{params[:id]}"
      redirect_to product_path(product_id)
    else
      flash[:error] = "Failed to destroy dimension #{params[:id]}"
      redirect_to edit_dimension_path(dimension)
    end
  end

  private

  def dimension_params(*args)
    params.require(:dimension).permit(*args)
  end
end
