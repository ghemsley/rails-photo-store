class QuantitiesController < ApplicationController
  def index
    @quantities = Quantity.includes(:product).has_been_purchased.order_by_amount
  end

  def show
    @quantity = Quantity.includes(:product).find(params[:id])
  end
end
