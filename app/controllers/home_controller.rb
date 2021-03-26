class HomeController < ApplicationController
  def index
    @categories = Category.includes(products: { dimensions: :price_modifier })
  end
end
