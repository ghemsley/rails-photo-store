class QuantitiesController < ApplicationController
  def index
    @quantities = Quantity.all
  end

  def show
    @quantity = Quantity.find(params[:id])
  end
end
