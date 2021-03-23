class SearchesController < ApplicationController
  def search
    @query = search_params(:query)
    @products = Product.name_or_description_contains(@query)
  end

  def search_params(*args)
    params.require(*args)
  end
end
