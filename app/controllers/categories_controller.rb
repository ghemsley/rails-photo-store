class CategoriesController < ApplicationController
  def index
    @categories = Category.all
  end

  def show
    @category = Category.includes(products: { dimensions: :price_modifier }).find(params[:id])
  end

  def new
    redirect_unless_admin_signed_in
    @category = Category.new
  end

  def create
    category = Category.new
    if update_category(category)
      redirect_to category_path(category)
    else
      @category = category
      render :new
    end
  end

  def edit
    redirect_unless_admin_signed_in
    @category = Category.find(params[:id])
  end

  def update
    category = Category.find(params[:id])
    if update_category(category)
      redirect_to category_path(category)
    else
      @category = category
      render :edit
    end
  end

  def destroy
    category = Category.find(params[:id])
    if category.destroy
      flash[:notice] = "Destroyed category #{params[:id]}"
      redirect_to categories_path
    else
      flash[:error] = "Failed to destroy category #{params[:id]}"
      redirect_to edit_category_path(category)
    end
  end

  private

  def update_category(category)
    if category.update(category_params(:name, :description))
      flash[:notice] = "Saved category #{params[:category][:name]}"
      true
    else
      false
    end
  end

  def category_params(*args)
    params.require(:category).permit(*args)
  end
end
